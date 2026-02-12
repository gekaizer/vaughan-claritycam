import React from 'react';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import MapView, { Marker } from 'react-native-maps';

export default function MapThumbnail({ coordinate, size = 130 }) {
  if (!coordinate) {
    return (
      <View style={[styles.container, { width: size, height: size }]}>
        <ActivityIndicator color="#fff" />
      </View>
    );
  }

  return (
    <View style={[styles.container, { width: size, height: size }]}>
      <MapView
        style={StyleSheet.absoluteFill}
        region={{
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          latitudeDelta: 0.005,
          longitudeDelta: 0.005,
        }}
        mapType="satellite"
        scrollEnabled={false}
        zoomEnabled={false}
        rotateEnabled={false}
        pitchEnabled={false}
        showsUserLocation={false}
        showsPointsOfInterest={false}
        showsCompass={false}
        showsScale={false}
        showsTraffic={false}
        showsBuildings={false}
        showsIndoors={false}
        liteMode={true}
      >
        <Marker
          coordinate={{
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
          }}
          pinColor="red"
        />
      </MapView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#fff',
    overflow: 'hidden',
    backgroundColor: 'rgba(50,50,50,0.5)',
  },
});
