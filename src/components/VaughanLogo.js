import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function VaughanLogo() {
  return (
    <View style={styles.container}>
      <View style={styles.shield}>
        <Text style={styles.vText}>V</Text>
      </View>
      <Text style={styles.vaughanText}>VAUGHAN</Text>
      <Text style={styles.clarityText}>ClarityCam</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
  },
  shield: {
    width: 50,
    height: 50,
    borderRadius: 6,
    borderWidth: 1.5,
    borderColor: 'rgba(255,255,255,0.8)',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#00598A',
  },
  vText: {
    fontSize: 30,
    fontWeight: 'bold',
    color: '#fff',
    fontFamily: 'serif',
  },
  vaughanText: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#fff',
    letterSpacing: 2,
    marginTop: 3,
    textShadowColor: '#000',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
  },
  clarityText: {
    fontSize: 8,
    fontWeight: '500',
    color: 'rgba(255,255,255,0.8)',
    marginTop: 1,
    textShadowColor: '#000',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
  },
});
