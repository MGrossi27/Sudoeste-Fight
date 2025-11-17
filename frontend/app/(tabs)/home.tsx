import { Ionicons } from '@expo/vector-icons';
import axios from 'axios';
import { useFocusEffect, useRouter, useLocalSearchParams } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useCallback, useState, useEffect } from 'react';
import { ActivityIndicator, FlatList, SafeAreaView, StyleSheet, Text, TextInput, TouchableOpacity, View, useWindowDimensions } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import AlunoCard from '../../components/AlunoCard';
import { API_URL } from '../../config/api';
import { useAuth } from '../../contexts/AuthContext';
import { devError, devLog } from '../../utils/helpers';
interface Aluno {
  matricula: string;
  nome_completo: string;
  email: string;
  telefone: string;
  cpf: string;
  data_cadastro: string;
}
export default function HomeScreen() {
  const router = useRouter();
  const params = useLocalSearchParams();
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const isWeb = width > 768;
  const { usuario, logout } = useAuth();
  const [alunos, setAlunos] = useState<Aluno[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredAlunos, setFilteredAlunos] = useState<Aluno[]>([]);
  const [totalAlunos, setTotalAlunos] = useState(0);
  const [currentPage, setCurrentPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);
  const [isSearching, setIsSearching] = useState(false);
  const [statusFilter, setStatusFilter] = useState<'todos' | 'ativos' | 'inativos'>('todos');
  const [showSuccessNotification, setShowSuccessNotification] = useState(false);
  const [notificationData, setNotificationData] = useState({ matricula: '', planoNome: '', dataVencimento: '' });
  const PAGE_SIZE = 200;
  useEffect(() => {
    if (params.cadastroSucesso === 'true') {
      setNotificationData({
        matricula: params.matricula as string || '',
        planoNome: params.planoNome as string || '',
        dataVencimento: params.dataVencimento as string || ''
      });
      setShowSuccessNotification(true);
      router.replace('/(tabs)/home');
      const timer = setTimeout(() => {
        setShowSuccessNotification(false);
      }, 5000);
      return () => clearTimeout(timer);
    }
  }, [params]);
  const fetchTotal = async (nome?: string, ativo?: boolean) => {
    try {
      let url = `${API_URL}/alunos/count`;
      const params = new URLSearchParams();
      if (nome) params.append('nome', nome);
      if (ativo !== undefined) params.append('ativo', String(ativo));
      if (params.toString()) {
        url += `?${params.toString()}`;
      }
      devLog("Buscando total com URL:", url);
      devLog("Parâmetros - nome:", nome, "ativo:", ativo);
      const response = await axios.get(url);
      setTotalAlunos(response.data.total);
      devLog("Total de alunos:", response.data.total);
    } catch (error) {
      devError("Erro ao buscar total:", error);
    }
  };
  const fetchAlunos = async (page: number, nome?: string, ativo?: boolean, append: boolean = false) => {
    try {
      if (!append) {
        setLoading(true);
      } else {
        setLoadingMore(true);
      }
      const skip = page * PAGE_SIZE;
      const params = new URLSearchParams({
        skip: String(skip),
        limit: String(PAGE_SIZE)
      });
      if (nome) params.append('nome', nome);
      if (ativo !== undefined) params.append('ativo', String(ativo));
      const url = `${API_URL}/alunos/?${params.toString()}`;
      devLog(`Carregando página ${page} (skip: ${skip}, limit: ${PAGE_SIZE}, ativo: ${ativo})`);
      devLog(`URL completa:`, url);
      const response = await axios.get(url);
      const novosAlunos = response.data;
      devLog(`Recebidos ${novosAlunos.length} alunos`);
      if (append) {
        setAlunos(prev => [...prev, ...novosAlunos]);
        setFilteredAlunos(prev => [...prev, ...novosAlunos]);
      } else {
        setAlunos(novosAlunos);
        setFilteredAlunos(novosAlunos);
      }
      setHasMore(novosAlunos.length === PAGE_SIZE);
    } catch (error: any) {
      devError("Erro ao carregar alunos:", error);
    } finally {
      setLoading(false);
      setLoadingMore(false);
    }
  };
  useFocusEffect(
    useCallback(() => {
      setCurrentPage(0);
      setHasMore(true);
      setSearchQuery('');
      setIsSearching(false);
      const ativoParam = statusFilter === 'todos' ? undefined : (statusFilter === 'ativos' ? true : false);
      fetchTotal(undefined, ativoParam);
      fetchAlunos(0, undefined, ativoParam);
    }, [statusFilter])
  );
  const executeSearch = () => {
    const ativoParam = statusFilter === 'todos' ? undefined : (statusFilter === 'ativos' ? true : false);
    if (searchQuery.trim() === '') {
      setIsSearching(false);
      setCurrentPage(0);
      setHasMore(true);
      fetchTotal(undefined, ativoParam);
      fetchAlunos(0, undefined, ativoParam);
    } else {
      devLog('Buscando:', searchQuery);
      setIsSearching(true);
      setCurrentPage(0);
      setHasMore(true);
      fetchTotal(searchQuery, ativoParam);
      fetchAlunos(0, searchQuery, ativoParam, false);
    }
  };
  const handleSearch = (text: string) => {
    setSearchQuery(text);
  };
  const handleLoadMore = () => {
    if (!loadingMore && hasMore) {
      const nextPage = currentPage + 1;
      setCurrentPage(nextPage);
      const ativoParam = statusFilter === 'todos' ? undefined : (statusFilter === 'ativos' ? true : false);
      const searchTerm = isSearching ? searchQuery : undefined;
      fetchAlunos(nextPage, searchTerm, ativoParam, true);
    }
  };
  const handleStatusFilterChange = (newFilter: 'todos' | 'ativos' | 'inativos') => {
    devLog(`Mudando filtro de status de "${statusFilter}" para "${newFilter}"`);
    setStatusFilter(newFilter);
    setCurrentPage(0);
    setHasMore(true);
    setSearchQuery('');
    setIsSearching(false);
    const ativoParam = newFilter === 'todos' ? undefined : (newFilter === 'ativos' ? true : false);
    devLog(`Valor do parâmetro ativo:`, ativoParam);
    fetchTotal(undefined, ativoParam);
    fetchAlunos(0, undefined, ativoParam);
  };
  const handleAlunoPress = (matricula: string) => {
    router.push(`/(tabs)/${matricula}`);
  };
  const handleAddAluno = () => {
    router.push('/(tabs)/addAluno');
  };
  if (loading) {
    return (
      <View style={[styles.container, { justifyContent: 'center', paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color="#FFD700" />
      </View>
    );
  }
  return (
    <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>
      <View style={[styles.contentWrapper, isWeb && styles.contentWrapperWeb]}>
        {}
        {showSuccessNotification && (
          <View style={styles.successNotification}>
            <View style={styles.notificationContent}>
              <Ionicons name="checkmark-circle" size={24} color="#2E8B57" />
              <View style={styles.notificationText}>
                <Text style={styles.notificationTitle}>Aluno cadastrado com sucesso!</Text>
                <Text style={styles.notificationDetails}>
                  Matrícula: {notificationData.matricula}
                </Text>
                <Text style={styles.notificationDetails}>
                  Plano: {notificationData.planoNome}
                </Text>
                <Text style={styles.notificationDetails}>
                  Vencimento: {notificationData.dataVencimento}
                </Text>
              </View>
              <TouchableOpacity
                onPress={() => setShowSuccessNotification(false)}
                style={styles.notificationClose}
              >
                <Ionicons name="close" size={20} color="#FFFFFF" />
              </TouchableOpacity>
            </View>
          </View>
        )}
        <View style={styles.header}>
          <View>
            <Text style={styles.title}>Alunos</Text>
            <Text style={styles.subtitle}>
              {searchQuery.trim() === ''
                ? `${totalAlunos} alunos cadastrados`
                : `${filteredAlunos.length} de ${totalAlunos} alunos`
              }
            </Text>
          </View>
          <TouchableOpacity
            onPress={logout}
            style={styles.logoutButton}
            activeOpacity={0.7}
            hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
          >
            <Ionicons name="log-out-outline" size={28} color="#ff4444" />
          </TouchableOpacity>
        </View>
        <View style={styles.searchContainer}>
          <Ionicons name="search" size={20} color="#AAAAAA" style={styles.searchIcon} />
          <TextInput
            style={styles.searchInput}
            placeholder="Buscar por nome ou matrícula..."
            placeholderTextColor="#777"
            value={searchQuery}
            onChangeText={handleSearch}
            onSubmitEditing={executeSearch}
            returnKeyType="search"
          />
          {searchQuery.trim() !== '' && (
            <TouchableOpacity
              onPress={() => {
                setSearchQuery('');
                setIsSearching(false);
                setCurrentPage(0);
                setHasMore(true);
                const ativoParam = statusFilter === 'todos' ? undefined : (statusFilter === 'ativos' ? true : false);
                fetchTotal(undefined, ativoParam);
                fetchAlunos(0, undefined, ativoParam);
              }}
              style={styles.clearButton}
            >
              <Ionicons name="close-circle" size={20} color="#AAAAAA" />
            </TouchableOpacity>
          )}
          <TouchableOpacity
            onPress={executeSearch}
            style={styles.searchButton}
            activeOpacity={0.7}
          >
            <Ionicons name="search" size={20} color="#000" />
          </TouchableOpacity>
        </View>
        {}
        <View style={styles.filterContainer}>
          <TouchableOpacity
            style={[
              styles.filterButton,
              statusFilter === 'todos' && styles.filterButtonActive
            ]}
            onPress={() => handleStatusFilterChange('todos')}
          >
            <Text style={[
              styles.filterButtonText,
              statusFilter === 'todos' && styles.filterButtonTextActive
            ]}>
              Todos
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[
              styles.filterButton,
              styles.filterButtonAtivos,
              statusFilter === 'ativos' && styles.filterButtonActivosActive
            ]}
            onPress={() => handleStatusFilterChange('ativos')}
          >
            <Text style={[
              styles.filterButtonText,
              styles.filterButtonTextAtivos,
              statusFilter === 'ativos' && styles.filterButtonTextActivosActive
            ]}>
              Ativos
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[
              styles.filterButton,
              styles.filterButtonInativos,
              statusFilter === 'inativos' && styles.filterButtonInativosActive
            ]}
            onPress={() => handleStatusFilterChange('inativos')}
          >
            <Text style={[
              styles.filterButtonText,
              styles.filterButtonTextInativos,
              statusFilter === 'inativos' && styles.filterButtonTextInativosActive
            ]}>
              Inativos
            </Text>
          </TouchableOpacity>
        </View>
      <FlatList
        data={filteredAlunos}
        keyExtractor={(item) => item.matricula}
        renderItem={({ item }) => (
          <AlunoCard
            matricula={item.matricula}
            nome={item.nome_completo}
            email={item.email}
            telefone={item.telefone}
            onPress={() => handleAlunoPress(item.matricula)}
          />
        )}
        onEndReached={handleLoadMore}
        onEndReachedThreshold={0.5}
        ListFooterComponent={
          loadingMore ? (
            <View style={styles.loadingMore}>
              <ActivityIndicator size="small" color="#FFD700" />
              <Text style={styles.loadingMoreText}>Carregando mais alunos...</Text>
            </View>
          ) : null
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>Nenhum aluno encontrado</Text>
          </View>
        }
        style={styles.list}
        contentContainerStyle={styles.listContent}
      />
      <TouchableOpacity style={styles.fab} onPress={handleAddAluno}>
        <Text style={styles.fabText}>+</Text>
      </TouchableOpacity>
      </View>
      <StatusBar style="light" />
    </SafeAreaView>
  );
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212'
  },
  contentWrapper: {
    flex: 1,
  },
  contentWrapperWeb: {
    maxWidth: 1200,
    width: '100%',
    alignSelf: 'center',
  },
  successNotification: {
    backgroundColor: '#1A3A1A',
    marginHorizontal: 20,
    marginTop: 10,
    marginBottom: 10,
    borderRadius: 12,
    borderLeftWidth: 4,
    borderLeftColor: '#2E8B57',
    elevation: 8,
    shadowColor: '#2E8B57',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  notificationContent: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    padding: 16,
    gap: 12,
  },
  notificationText: {
    flex: 1,
    gap: 4,
  },
  notificationTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#FFFFFF',
    marginBottom: 8,
  },
  notificationDetails: {
    fontSize: 14,
    color: '#CCCCCC',
    lineHeight: 20,
  },
  notificationClose: {
    padding: 4,
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 20,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  title: {
    fontSize: 36,
    fontWeight: '800',
    color: '#FFD700',
    marginBottom: 8,
    letterSpacing: 0.5,
  },
  subtitle: {
    fontSize: 15,
    color: '#AAAAAA',
    fontWeight: '500',
  },
  logoutButton: {
    padding: 12,
    backgroundColor: '#2a2a2a',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ff4444',
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#282828',
    marginHorizontal: 20,
    marginBottom: 16,
    borderRadius: 12,
    paddingHorizontal: 16,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  searchIcon: {
    marginRight: 12,
  },
  searchInput: {
    flex: 1,
    color: '#FFFFFF',
    paddingVertical: 14,
    fontSize: 16,
    fontWeight: '500',
  },
  clearButton: {
    padding: 4,
    marginLeft: 8,
  },
  searchButton: {
    backgroundColor: '#FFD700',
    padding: 10,
    borderRadius: 8,
    marginLeft: 8,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 2,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 3,
  },
  filterContainer: {
    flexDirection: 'row',
    marginHorizontal: 20,
    marginBottom: 16,
    gap: 8,
  },
  filterButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 10,
    paddingHorizontal: 12,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    backgroundColor: '#282828',
    gap: 6,
  },
  filterButtonActive: {
    backgroundColor: '#FFD700',
    borderColor: '#FFD700',
  },
  filterButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#AAAAAA',
  },
  filterButtonTextActive: {
    color: '#000000',
  },
  filterButtonAtivos: {
    borderColor: '#2E8B57',
  },
  filterButtonActivosActive: {
    backgroundColor: '#2E8B57',
    borderColor: '#2E8B57',
  },
  filterButtonTextAtivos: {
    color: '#2E8B57',
  },
  filterButtonTextActivosActive: {
    color: '#FFFFFF',
  },
  filterButtonInativos: {
    borderColor: '#B22222',
  },
  filterButtonInativosActive: {
    backgroundColor: '#B22222',
    borderColor: '#B22222',
  },
  filterButtonTextInativos: {
    color: '#B22222',
  },
  filterButtonTextInativosActive: {
    color: '#FFFFFF',
  },
  list: {
    flex: 1,
  },
  listContent: {
    paddingBottom: 100,
    paddingHorizontal: 4,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 80,
    paddingHorizontal: 40,
  },
  emptyText: {
    color: '#777',
    fontSize: 16,
    textAlign: 'center',
    lineHeight: 24,
  },
  fab: {
    position: 'absolute',
    right: 24,
    bottom: 24,
    backgroundColor: '#FFD700',
    width: 64,
    height: 64,
    borderRadius: 32,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 8,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.4,
    shadowRadius: 8,
  },
  fabText: {
    fontSize: 32,
    color: '#000000',
    fontWeight: '700',
    marginTop: -2,
  },
  loadingMore: {
    paddingVertical: 20,
    alignItems: 'center',
  },
  loadingMoreText: {
    color: '#AAAAAA',
    fontSize: 14,
    marginTop: 8,
    fontWeight: '500',
  },
});
