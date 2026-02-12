import React from 'react';
import { View, StyleSheet } from 'react-native';
import Svg, {
  Circle,
  Line,
  Text as SvgText,
  Polygon,
  G,
} from 'react-native-svg';

export default function CompassRose({ heading = 0, size = 90 }) {
  const center = size / 2;
  const radius = size / 2 - 2;

  // Generate tick marks (every 10 degrees)
  const ticks = Array.from({ length: 36 }, (_, i) => {
    const angle = i * 10;
    const isMajor = i % 9 === 0;
    const outerR = radius - 2;
    const innerR = outerR - (isMajor ? 10 : 5);
    const rad = (angle * Math.PI) / 180;
    return {
      x1: center + innerR * Math.sin(rad),
      y1: center - innerR * Math.cos(rad),
      x2: center + outerR * Math.sin(rad),
      y2: center - outerR * Math.cos(rad),
      isMajor,
    };
  });

  // Cardinal direction labels
  const labels = [
    { text: 'N', angle: 0, color: '#FF3B30' },
    { text: 'E', angle: 90, color: '#fff' },
    { text: 'S', angle: 180, color: '#fff' },
    { text: 'W', angle: 270, color: '#fff' },
  ];

  const labelRadius = radius - 18;

  return (
    <View style={[styles.container, { width: size, height: size }]}>
      <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        {/* Background circle */}
        <Circle
          cx={center}
          cy={center}
          r={radius}
          fill="rgba(0,0,0,0.5)"
          stroke="rgba(255,255,255,0.8)"
          strokeWidth={2}
        />

        {/* Rotating group — rotates opposite to heading so N always points north */}
        <G rotation={-heading} origin={`${center}, ${center}`}>
          {/* Tick marks */}
          {ticks.map((tick, i) => (
            <Line
              key={`tick-${i}`}
              x1={tick.x1}
              y1={tick.y1}
              x2={tick.x2}
              y2={tick.y2}
              stroke={tick.isMajor ? '#fff' : 'rgba(255,255,255,0.4)'}
              strokeWidth={tick.isMajor ? 2 : 1}
            />
          ))}

          {/* Cardinal labels */}
          {labels.map(({ text, angle, color }) => {
            const rad = (angle * Math.PI) / 180;
            const x = center + labelRadius * Math.sin(rad);
            const y = center - labelRadius * Math.cos(rad);
            return (
              <SvgText
                key={text}
                x={x}
                y={y}
                fill={color}
                fontSize={11}
                fontWeight="bold"
                textAnchor="middle"
                alignmentBaseline="central"
              >
                {text}
              </SvgText>
            );
          })}

          {/* North needle (red triangle) */}
          <Polygon
            points={`${center},${center - 20} ${center - 5},${center} ${center + 5},${center}`}
            fill="#FF3B30"
          />

          {/* South needle (white triangle) */}
          <Polygon
            points={`${center},${center + 20} ${center - 5},${center} ${center + 5},${center}`}
            fill="rgba(255,255,255,0.6)"
          />

          {/* Center dot */}
          <Circle cx={center} cy={center} r={3} fill="#fff" />
        </G>
      </Svg>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    // no extra styling needed; SVG handles everything
  },
});
