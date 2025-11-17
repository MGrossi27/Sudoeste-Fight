import { Ionicons } from '@expo/vector-icons';
import axios from 'axios';
import { StatusBar } from 'expo-status-bar';
import { useState } from 'react';
import {
    ActivityIndicator,
    Alert,
    Image,
    KeyboardAvoidingView,
    Platform,
    SafeAreaView,
    ScrollView,
    StyleSheet,
    Text,
    TextInput,
    TouchableOpacity,
    View,
    useWindowDimensions
} from 'react-native';
import { API_URL } from '../config/api';
import { useAuth } from '../contexts/AuthContext';
export default function LoginScreen() {
  const { login } = useAuth();
  const { width } = useWindowDimensions();
  const isWeb = width > 768;
  const [username, setUsername] = useState('');
  const [senha, setSenha] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const handleLogin = async () => {
    if (!username.trim()) {
      Alert.alert('Erro', 'Por favor, informe o usuário');
      return;
    }
    if (!senha.trim()) {
      Alert.alert('Erro', 'Por favor, informe a senha');
      return;
    }
    try {
      setLoading(true);

      const response = await axios.post(`${API_URL}/auth/login`, {
        username: username.trim(),
        senha: senha
      });
      if (response.data.sucesso) {
        await login(response.data.usuario);
        Alert.alert('Sucesso', `Bem-vindo, ${response.data.usuario.nome_completo}!`);
      } else {
        Alert.alert('Erro', response.data.mensagem || 'Credenciais inválidas');
      }
    } catch (error: any) {
      if (error.response?.status === 401) {
        Alert.alert('Erro', 'Usuário ou senha incorretos');
      } else if (error.response?.status === 403) {
        Alert.alert('Erro', 'Usuário inativo. Entre em contato com o administrador.');
      } else {
        Alert.alert('Erro', 'Não foi possível realizar o login. Verifique sua conexão.');
      }
    } finally {
      setLoading(false);
    }
  };
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="light" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={styles.keyboardView}
        >
          <View style={[styles.content, isWeb && styles.contentWeb]}>
            {}
            <View style={styles.loginCard}>
              {}
              <View style={styles.header}>
                <Image
                  source={require('../assets/images/logo.png')}
                  style={styles.logo}
                  resizeMode="contain"
                />
                <Text style={styles.title}>Sudoeste Fight</Text>
                <Text style={styles.subtitle}>Sistema de Gerenciamento</Text>
              </View>
              {}
              <View style={styles.form}>
            {}
            <View style={styles.inputContainer}>
              <Ionicons name="person-outline" size={20} color="#AAAAAA" style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Usuário"
                placeholderTextColor="#666"
                value={username}
                onChangeText={setUsername}
                autoCapitalize="none"
                autoCorrect={false}
                editable={!loading}
              />
            </View>
            {}
            <View style={styles.inputContainer}>
              <Ionicons name="lock-closed-outline" size={20} color="#AAAAAA" style={styles.inputIcon} />
              <TextInput
                style={styles.input}
                placeholder="Senha"
                placeholderTextColor="#666"
                value={senha}
                onChangeText={setSenha}
                secureTextEntry={!showPassword}
                autoCapitalize="none"
                autoCorrect={false}
                editable={!loading}
              />
              <TouchableOpacity
                style={styles.eyeIcon}
                onPress={() => setShowPassword(!showPassword)}
              >
                <Ionicons
                  name={showPassword ? 'eye-outline' : 'eye-off-outline'}
                  size={20}
                  color="#AAAAAA"
                />
              </TouchableOpacity>
            </View>
            {}
            <TouchableOpacity
              style={[styles.button, loading && styles.buttonDisabled]}
              onPress={handleLogin}
              disabled={loading}
            >
              {loading ? (
                <ActivityIndicator color="#000000" />
              ) : (
                <>
                  <Text style={styles.buttonText}>Entrar</Text>
                  <Ionicons name="arrow-forward" size={20} color="#000000" />
                </>
              )}
            </TouchableOpacity>
          </View>
              {}
              <View style={styles.footer}>
                <Text style={styles.footerText}>© 2025 Sudoeste Fight • Versão 1.0.0</Text>
              </View>
            </View>
          </View>
        </KeyboardAvoidingView>
      </ScrollView>
    </SafeAreaView>
  );
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212',
  },
  scrollContent: {
    flexGrow: 1,
  },
  keyboardView: {
    flex: 1,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 20,
    paddingVertical: 40,
  },
  contentWeb: {
    maxWidth: 500,
    width: '100%',
    alignSelf: 'center',
  },
  loginCard: {
    backgroundColor: '#1E1E1E',
    borderRadius: 20,
    padding: 48,
    borderWidth: 1,
    borderColor: '#333',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 12,
  },
  header: {
    alignItems: 'center',
    marginBottom: 48,
  },
  logo: {
    width: 180,
    height: 180,
    marginBottom: 28,
  },
  title: {
    fontSize: 32,
    fontWeight: '800',
    color: '#FFD700',
    marginBottom: 8,
    letterSpacing: 0.5,
  },
  subtitle: {
    fontSize: 16,
    color: '#AAA',
    fontWeight: '500',
  },
  form: {
    width: '100%',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#282828',
    borderRadius: 12,
    marginBottom: 16,
    paddingHorizontal: 18,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    height: 56,
  },
  inputIcon: {
    marginRight: 12,
  },
  input: {
    flex: 1,
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '500',
  },
  eyeIcon: {
    padding: 8,
  },
  button: {
    flexDirection: 'row',
    backgroundColor: '#FFD700',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 8,
    elevation: 4,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 8,
    gap: 8,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#000000',
    fontSize: 17,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  footer: {
    alignItems: 'center',
    marginTop: 40,
    paddingTop: 32,
    borderTopWidth: 1,
    borderTopColor: '#333',
  },
  footerText: {
    color: '#666',
    fontSize: 12,
    fontWeight: '400',
  },
});
