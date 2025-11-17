import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
interface AlunoCardProps {
  matricula: string;
  nome: string;
  email: string;
  telefone: string;
  onPress?: () => void;
}
export default function AlunoCard({ matricula, nome, email, telefone, onPress }: AlunoCardProps) {
  return (
    <TouchableOpacity style={styles.card} onPress={onPress} activeOpacity={0.7}>
      <View style={styles.header}>
        <Text style={styles.matricula}>Mat: {matricula}</Text>
        <View style={styles.badge}>
          <Ionicons name="person" size={16} color="#000000" />
        </View>
      </View>
      <Text style={styles.nome}>{nome}</Text>
      <View style={styles.infoRow}>
        <Ionicons name="mail" size={14} color="#CCCCCC" style={styles.icon} />
        <Text style={styles.infoText}>{email}</Text>
      </View>
      <View style={styles.infoRow}>
        <Ionicons name="call" size={14} color="#CCCCCC" style={styles.icon} />
        <Text style={styles.infoText}>{telefone}</Text>
      </View>
    </TouchableOpacity>
  );
}
const styles = StyleSheet.create({
  card: {
    backgroundColor: '#282828',
    borderRadius: 16,
    padding: 20,
    marginHorizontal: 16,
    marginVertical: 8,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  matricula: {
    color: '#FFD700',
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  badge: {
    backgroundColor: '#FFD700',
    borderRadius: 16,
    width: 32,
    height: 32,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 2,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
  },
  badgeText: {
    fontSize: 16,
  },
  nome: {
    color: '#FFFFFF',
    fontSize: 19,
    fontWeight: '700',
    marginBottom: 12,
    letterSpacing: 0.3,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 6,
    paddingVertical: 2,
  },
  icon: {
    marginRight: 10,
  },
  infoText: {
    color: '#CCCCCC',
    fontSize: 14,
    flex: 1,
    fontWeight: '500',
  },
});
