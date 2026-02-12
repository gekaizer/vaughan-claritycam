import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  StyleSheet,
  Animated,
  Dimensions,
  SafeAreaView,
} from 'react-native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import * as Location from 'expo-location';
import * as MediaLibrary from 'expo-media-library';
import * as Sharing from 'expo-sharing';
import { captureRef } from 'react-native-view-shot';

import MapThumbnail from '../components/MapThumbnail';
import CompassRose from '../components/CompassRose';
import InfoOverlay from '../components/InfoOverlay';
import VaughanLogo from '../components/VaughanLogo';
import { formatDMS, cardinalDirection, formatDateTime } from '../utils/formatLocation';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

export default function CameraScreen() {
  // Permissions
  const [cameraPermission, requestCameraPermission] = useCameraPermissions();
  const [locationGranted, setLocationGranted] = useState(false);

  // Location state
  const [location, setLocation] = useState(null);
  const [heading, setHeading] = useState(null);
  const [address, setAddress] = useState(null);

  // Capture state
  const [mode, setMode] = useState('camera'); // 'camera' | 'preview'
  const [capturedPhoto, setCapturedPhoto] = useState(null);
  const [showSaved, setShowSaved] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [captureTime, setCaptureTime] = useState(null);

  // Refs
  const cameraRef = useRef(null);
  const compositeRef = useRef(null);
  const flashOpacity = useRef(new Animated.Value(0)).current;
  const locationSubRef = useRef(null);
  const headingSubRef = useRef(null);

  // ---------------------------
  // Request location permission
  // ---------------------------
  useEffect(() => {
    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      const granted = status === 'granted';
      setLocationGranted(granted);

      if (granted) {
        locationSubRef.current = await Location.watchPositionAsync(
          { accuracy: Location.Accuracy.High, distanceInterval: 2 },
          async (loc) => {
            setLocation(loc);
            try {
              const results = await Location.reverseGeocodeAsync(loc.coords);
              if (results.length > 0) setAddress(results[0]);
            } catch (_) {}
          },
        );

        headingSubRef.current = await Location.watchHeadingAsync((h) => {
          setHeading(h);
        });
      }
    })();

    return () => {
      locationSubRef.current?.remove();
      headingSubRef.current?.remove();
    };
  }, []);

  // ---------------------------
  // Derived display strings
  // ---------------------------
  const now = mode === 'preview' && captureTime ? captureTime : new Date();
  const dateTimeStr = formatDateTime(now);
  const latStr = location ? formatDMS(location.coords.latitude, true) : '\u2014';
  const lonStr = location ? formatDMS(location.coords.longitude, false) : '\u2014';
  const headingDeg = heading?.trueHeading ?? 0;
  const headingStr =
    heading && heading.trueHeading >= 0
      ? `${Math.round(heading.trueHeading)}\u00B0 ${cardinalDirection(heading.trueHeading)}`
      : '\u2014';
  const addressStr = address
    ? [address.streetNumber, address.street].filter(Boolean).join(' ') || '\u2014'
    : '\u2014';
  const cityStr = address
    ? [address.city, address.region, address.postalCode].filter(Boolean).join(' ')
    : '\u2014';
  const countryStr = address?.country || '\u2014';

  // ---------------------------
  // Capture photo
  // ---------------------------
  const handleCapture = useCallback(async () => {
    if (!cameraRef.current || isProcessing) return;
    setIsProcessing(true);
    setCaptureTime(new Date());

    // Flash effect
    Animated.sequence([
      Animated.timing(flashOpacity, { toValue: 1, duration: 80, useNativeDriver: true }),
      Animated.timing(flashOpacity, { toValue: 0, duration: 120, useNativeDriver: true }),
    ]).start();

    try {
      const photo = await cameraRef.current.takePictureAsync({ quality: 0.9 });
      setCapturedPhoto(photo.uri);
      setMode('preview');
    } catch (e) {
      console.error('Capture failed:', e);
      setIsProcessing(false);
    }
  }, [isProcessing, flashOpacity]);

  // ---------------------------
  // Auto-save composited image
  // ---------------------------
  useEffect(() => {
    if (mode !== 'preview' || !capturedPhoto) return;

    const saveComposite = async () => {
      // Wait for the image and map tiles to render
      await new Promise((resolve) => setTimeout(resolve, 1200));

      try {
        const uri = await captureRef(compositeRef, {
          format: 'jpg',
          quality: 0.95,
        });

        const { status } = await MediaLibrary.requestPermissionsAsync();
        if (status === 'granted') {
          await MediaLibrary.saveToLibraryAsync(uri);
          setShowSaved(true);
          setTimeout(() => setShowSaved(false), 2000);
        }
      } catch (e) {
        console.error('Save failed:', e);
      }

      setIsProcessing(false);
    };

    saveComposite();
  }, [mode, capturedPhoto]);

  // ---------------------------
  // Preview actions
  // ---------------------------
  const handleDone = () => {
    setMode('camera');
    setCapturedPhoto(null);
    setShowSaved(false);
    setCaptureTime(null);
  };

  const handleShare = async () => {
    try {
      const uri = await captureRef(compositeRef, { format: 'jpg', quality: 0.95 });
      await Sharing.shareAsync(uri);
    } catch (e) {
      console.error('Share failed:', e);
    }
  };

  // ---------------------------
  // Overlay elements (shared between camera and preview modes)
  // ---------------------------
  const overlayElements = (
    <View style={styles.overlayContainer} pointerEvents="none">
      {/* Top row */}
      <View style={styles.topRow}>
        <MapThumbnail coordinate={location?.coords} />
        <InfoOverlay
          dateTime={dateTimeStr}
          latitude={latStr}
          longitude={lonStr}
          heading={headingStr}
          address={addressStr}
          cityProvincePostal={cityStr}
          country={countryStr}
        />
      </View>

      {/* Bottom row */}
      <View style={styles.bottomRow}>
        <CompassRose heading={headingDeg} />
        <VaughanLogo />
      </View>
    </View>
  );

  // ---------------------------
  // Permission screens
  // ---------------------------
  if (!cameraPermission) {
    return <View style={styles.container} />;
  }

  if (!cameraPermission.granted) {
    return (
      <View style={styles.permissionScreen}>
        <Text style={styles.permissionIcon}>📷</Text>
        <Text style={styles.permissionTitle}>Camera Access Required</Text>
        <Text style={styles.permissionBody}>
          ClarityCam needs camera and location access to stamp photos with GPS
          data.
        </Text>
        <TouchableOpacity style={styles.permissionButton} onPress={requestCameraPermission}>
          <Text style={styles.permissionButtonText}>Grant Camera Access</Text>
        </TouchableOpacity>
      </View>
    );
  }

  // ---------------------------
  // Preview mode
  // ---------------------------
  if (mode === 'preview' && capturedPhoto) {
    return (
      <View style={styles.container}>
        {/* Composited view (captured by view-shot) */}
        <View
          ref={compositeRef}
          collapsable={false}
          style={styles.compositeContainer}
        >
          <Image
            source={{ uri: capturedPhoto }}
            style={styles.fullImage}
            resizeMode="cover"
          />
          {overlayElements}
        </View>

        {/* Controls overlay */}
        <SafeAreaView style={styles.previewControls}>
          <View style={styles.previewTopBar}>
            <TouchableOpacity onPress={handleDone} style={styles.closeButton}>
              <Text style={styles.closeButtonText}>✕</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.previewBottomBar}>
            <TouchableOpacity onPress={handleShare} style={styles.actionButton}>
              <Text style={styles.actionIcon}>↗</Text>
              <Text style={styles.actionLabel}>Share</Text>
            </TouchableOpacity>

            <TouchableOpacity onPress={handleDone} style={styles.actionButton}>
              <Text style={styles.actionIcon}>✓</Text>
              <Text style={styles.actionLabel}>Done</Text>
            </TouchableOpacity>
          </View>
        </SafeAreaView>

        {/* Saved confirmation */}
        {showSaved && (
          <View style={styles.savedBadge}>
            <Text style={styles.savedText}>✓ Photo Saved</Text>
          </View>
        )}
      </View>
    );
  }

  // ---------------------------
  // Camera mode
  // ---------------------------
  return (
    <View style={styles.container}>
      <CameraView ref={cameraRef} style={styles.camera} facing="back">
        {overlayElements}

        {/* Capture button */}
        <SafeAreaView style={styles.captureArea}>
          <TouchableOpacity
            style={styles.captureButton}
            onPress={handleCapture}
            disabled={isProcessing}
            activeOpacity={0.7}
          >
            <View style={styles.captureOuter}>
              <View style={styles.captureInner} />
            </View>
          </TouchableOpacity>
        </SafeAreaView>
      </CameraView>

      {/* Flash effect */}
      <Animated.View
        style={[styles.flash, { opacity: flashOpacity }]}
        pointerEvents="none"
      />
    </View>
  );
}

// ---------------------------
// Styles
// ---------------------------
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  camera: {
    flex: 1,
  },

  // Overlays
  overlayContainer: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'space-between',
    padding: 12,
    paddingTop: 50,
    paddingBottom: 20,
  },
  topRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  bottomRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    marginBottom: 80,
  },

  // Capture button
  captureArea: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    alignItems: 'center',
    paddingBottom: 30,
  },
  captureButton: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  captureOuter: {
    width: 72,
    height: 72,
    borderRadius: 36,
    borderWidth: 4,
    borderColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  captureInner: {
    width: 58,
    height: 58,
    borderRadius: 29,
    backgroundColor: '#fff',
  },

  // Flash
  flash: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: '#fff',
  },

  // Preview mode
  compositeContainer: {
    flex: 1,
  },
  fullImage: {
    ...StyleSheet.absoluteFillObject,
    width: '100%',
    height: '100%',
  },
  previewControls: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'space-between',
  },
  previewTopBar: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    padding: 16,
    paddingTop: 50,
  },
  closeButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(0,0,0,0.5)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  closeButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  previewBottomBar: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 50,
    paddingBottom: 40,
  },
  actionButton: {
    alignItems: 'center',
  },
  actionIcon: {
    color: '#fff',
    fontSize: 28,
    textShadowColor: '#000',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 4,
  },
  actionLabel: {
    color: '#fff',
    fontSize: 12,
    marginTop: 4,
    textShadowColor: '#000',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 4,
  },

  // Saved badge
  savedBadge: {
    position: 'absolute',
    bottom: 130,
    alignSelf: 'center',
    backgroundColor: 'rgba(0,0,0,0.7)',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 12,
  },
  savedText: {
    color: '#4CD964',
    fontSize: 16,
    fontWeight: '600',
  },

  // Permission screen
  permissionScreen: {
    flex: 1,
    backgroundColor: '#000',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  permissionIcon: {
    fontSize: 60,
    marginBottom: 20,
  },
  permissionTitle: {
    color: '#fff',
    fontSize: 22,
    fontWeight: '600',
    marginBottom: 12,
  },
  permissionBody: {
    color: '#888',
    fontSize: 15,
    textAlign: 'center',
    lineHeight: 22,
    marginBottom: 30,
  },
  permissionButton: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 10,
  },
  permissionButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
