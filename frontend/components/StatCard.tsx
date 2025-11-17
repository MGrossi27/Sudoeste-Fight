import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
interface StatCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  color?: string;
}
export default function StatCard({ title, value, subtitle, color = '#FFD700' }: StatCardProps) {
  return (
    <View style={[styles.card, { borderLeftColor: color, borderLeftWidth: 4 }]}>
      <View style={styles.content}>
        <Text style={styles.title}>{title}</Text>
        <Text style={[styles.value, { color }]}>{value}</Text>
        {subtitle && <Text style={styles.subtitle}>{subtitle}</Text>}
      </View>
    </View>
  );
}
const styles = StyleSheet.create({
  card: {
    backgroundColor: '#282828',
    borderRadius: 16,
    padding: 20,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
  },
  content: {
    flex: 1,
  },
  title: {
    color: '#AAAAAA',
    fontSize: 14,
    marginBottom: 8,
    fontWeight: '600',
    letterSpacing: 0.3,
  },
  value: {
    fontSize: 32,
    fontWeight: '800',
    marginBottom: 6,
    letterSpacing: 0.5,
  },
  subtitle: {
    color: '#999',
    fontSize: 13,
    fontWeight: '500',
  },
});
