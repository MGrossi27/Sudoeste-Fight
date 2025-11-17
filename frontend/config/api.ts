import { Platform } from 'react-native';

export const USE_MOCK_DATA = false;

const isWeb = Platform.OS === 'web';

export const API_URL = isWeb
  ? 'http://localhost:8001/api/v1'
  : 'http://192.168.100.11:8001/api/v1';
