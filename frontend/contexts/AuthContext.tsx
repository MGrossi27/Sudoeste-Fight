import AsyncStorage from '@react-native-async-storage/async-storage';
import { useRouter, useSegments } from 'expo-router';
import React, { createContext, useContext, useEffect, useRef, useState } from 'react';
import { Platform, AppState } from 'react-native';
const INACTIVITY_TIMEOUT = 5 * 60 * 1000; // 5 minutos em milissegundos
const SESSION_KEY = '@sudoeste_fight_session';
interface Usuario {
  id_usuario: number;
  username: string;
  nome_completo: string;
  email: string;
  ativo: boolean;
}
interface AuthContextType {
  usuario: Usuario | null;
  isAuthenticated: boolean;
  login: (usuario: Usuario) => void;
  logout: () => void;
  isLoading: boolean;
}
const AuthContext = createContext<AuthContextType>({
  usuario: null,
  isAuthenticated: false,
  login: () => {},
  logout: () => {},
  isLoading: true,
});
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth deve ser usado dentro de AuthProvider');
  }
  return context;
};
export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [usuario, setUsuario] = useState<Usuario | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();
  const segments = useSegments();
  const inactivityTimerRef = useRef<any>(null);
  const lastActivityRef = useRef<number>(Date.now());
  useEffect(() => {
    loadSession();
  }, []);
  useEffect(() => {
    const handleActivity = () => {
      lastActivityRef.current = Date.now();
      resetInactivityTimer();
    };
    if (Platform.OS === 'web' && typeof window !== 'undefined') {
      window.addEventListener('mousemove', handleActivity);
      window.addEventListener('keydown', handleActivity);
      window.addEventListener('click', handleActivity);
      window.addEventListener('scroll', handleActivity);
      window.addEventListener('touchstart', handleActivity);
    }
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      if (nextAppState === 'active') {
        handleActivity();
      }
    });
    return () => {
      if (Platform.OS === 'web' && typeof window !== 'undefined') {
        window.removeEventListener('mousemove', handleActivity);
        window.removeEventListener('keydown', handleActivity);
        window.removeEventListener('click', handleActivity);
        window.removeEventListener('scroll', handleActivity);
        window.removeEventListener('touchstart', handleActivity);
      }
      subscription.remove();
      if (inactivityTimerRef.current) {
        clearTimeout(inactivityTimerRef.current);
      }
    };
  }, []);
  useEffect(() => {
    if (usuario) {
      resetInactivityTimer();
    } else {
      if (inactivityTimerRef.current) {
        clearTimeout(inactivityTimerRef.current);
      }
    }
  }, [usuario]);
  useEffect(() => {
    if (isLoading) return;
    const inAuthGroup = segments[0] === '(tabs)';
    const inLoginScreen = segments[0] === 'login';
    if (!usuario && inAuthGroup) {
      router.replace('/login');
    } else if (usuario && inLoginScreen) {
      router.replace('/(tabs)/metricas');
    } else if (usuario && !inAuthGroup && !inLoginScreen) {
      router.replace('/(tabs)/metricas');
    }
  }, [usuario, segments, isLoading, router]);
  const loadSession = async () => {
    try {
      const sessionData = await AsyncStorage.getItem(SESSION_KEY);
      if (sessionData) {
        const { usuario: savedUser, timestamp } = JSON.parse(sessionData);
        const timeSinceLastActivity = Date.now() - timestamp;
        if (timeSinceLastActivity < INACTIVITY_TIMEOUT) {
          setUsuario(savedUser);
          lastActivityRef.current = timestamp;
        } else {
          await AsyncStorage.removeItem(SESSION_KEY);
        }
      }
    } catch (error) {
      console.error('Erro ao carregar sessÃ£o:', error);
    } finally {
      setIsLoading(false);
    }
  };
  const saveSession = async (user: Usuario) => {
    try {
      const sessionData = {
        usuario: user,
        timestamp: Date.now()
      };
      await AsyncStorage.setItem(SESSION_KEY, JSON.stringify(sessionData));
    } catch (error) {
      console.error('Erro ao salvar sessÃ£o:', error);
    }
  };
  const resetInactivityTimer = () => {
    if (inactivityTimerRef.current) {
      clearTimeout(inactivityTimerRef.current);
    }
    inactivityTimerRef.current = setTimeout(() => {
      logout();
    }, INACTIVITY_TIMEOUT);
    if (usuario) {
      saveSession(usuario);
    }
  };
  const login = async (dadosUsuario: Usuario) => {
    setUsuario(dadosUsuario);
    await saveSession(dadosUsuario);
    lastActivityRef.current = Date.now();
  };
  const logout = async () => {
    try {
      await AsyncStorage.removeItem(SESSION_KEY);
      setUsuario(null);
      if (inactivityTimerRef.current) {
        clearTimeout(inactivityTimerRef.current);
      }
      router.replace('/login');
    } catch (error) {
      console.error('Erro ao fazer logout:', error);
    }
  };
  return (
    <AuthContext.Provider
      value={{
        usuario,
        isAuthenticated: !!usuario,
        login,
        logout,
        isLoading,
      }}
    >
      {isLoading ? null : children}
    </AuthContext.Provider>
  );
}
