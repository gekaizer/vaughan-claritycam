import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function InfoOverlay({
  dateTime,
  latitude,
  longitude,
  heading,
  address,
  cityProvincePostal,
  country,
}) {
  return (
    <View style={styles.container}>
      <Text style={[styles.text, styles.bold]}>{dateTime}</Text>
      <Text style={styles.text}>{latitude}</Text>
      <Text style={styles.text}>{longitude}</Text>
      <Text style={styles.text}>{heading}</Text>
      <View style={styles.divider} />
      <Text style={[styles.text, styles.bold]}>{address}</Text>
      <Text style={styles.text}>{cityProvincePostal}</Text>
      <Text style={styles.text}>{country}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'rgba(0,0,0,0.55)',
    borderRadius: 8,
    padding: 10,
    alignItems: 'flex-end',
  },
  text: {
    color: '#fff',
    fontSize: 11,
    fontFamily: 'monospace',
    textShadowColor: '#000',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
    marginVertical: 1,
  },
  bold: {
    fontWeight: 'bold',
  },
  divider: {
    width: 160,
    height: 1,
    backgroundColor: 'rgba(255,255,255,0.6)',
    marginVertical: 4,
  },
});
