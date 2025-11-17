import { Ionicons } from '@expo/vector-icons';
import axios from 'axios';
import { useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import React, { useEffect, useState } from 'react';
import { ActivityIndicator, Alert, FlatList, Modal, Platform, SafeAreaView, StyleSheet, Text, TextInput, TouchableOpacity, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { API_URL } from '../../config/api';
import { devError, devLog, formatCurrency, formatDateBR, getDiasAtraso } from '../../utils/helpers';
interface PagamentoPendente {
  id_pagamento: number;
  id_inscricao: number;
  aluno_nome: string;
  aluno_matricula: string;
  data_vencimento: string;
  valor_total_devido: number;
  status: string;
}
const PagamentoCard = React.memo(({
  item,
  onPress,
  onPagar
}: {
  item: PagamentoPendente;
  onPress: (matricula: string) => void;
  onPagar: (idPagamento: number, alunoNome: string) => void;
}) => {
  const diasAtraso = getDiasAtraso(item.data_vencimento);
  const isAtrasado = item.status.toLowerCase() === 'atrasado';
  const isPendente = item.status.toLowerCase() === 'pendente';
  const corStatus = isAtrasado ? '#B22222' : '#FF8C00';
  const labelStatus = isAtrasado ? 'ATRASADO' : 'PENDENTE';
  return (
    <View style={[styles.pagamentoCard, { borderLeftColor: corStatus }]}>
      <View style={styles.cardContent}>
        {}
        <View style={styles.cardHeader}>
          <Text style={styles.alunoNome} numberOfLines={1}>{item.aluno_nome}</Text>
          <View style={[styles.statusBadge, { backgroundColor: corStatus }]}>
            <Text style={styles.statusBadgeText}>{labelStatus}</Text>
          </View>
        </View>
        {}
        <View style={styles.infoRow}>
          <View style={styles.infoLeft}>
            <Text style={styles.vencimentoText}>
              Vencimento: {formatDateBR(item.data_vencimento)}
            </Text>
            {isAtrasado && diasAtraso > 0 && (
              <View style={[styles.atrasoTag, { backgroundColor: corStatus }]}>
                <Text style={styles.atrasoText}>
                  {diasAtraso} {diasAtraso === 1 ? 'dia' : 'dias'} de atraso
                </Text>
              </View>
            )}
          </View>
          <Text style={styles.valorText}>{formatCurrency(Number(item.valor_total_devido))}</Text>
        </View>
        {}
        <View style={styles.actionsRow}>
          <TouchableOpacity
            style={styles.pagarButton}
            onPress={() => {




              onPagar(item.id_pagamento, item.aluno_nome);
            }}
            activeOpacity={0.8}
          >
            <Text style={styles.pagarButtonText}>Confirmar Pagamento</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.detailButton}
            onPress={() => onPress(item.aluno_matricula)}
            activeOpacity={0.8}
          >
            <Text style={styles.detailButtonText}>Ver</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
});
const SearchBar = React.memo(({
  searchText,
  onChangeText,
  onSubmit,
  onClear
}: {
  searchText: string;
  onChangeText: (text: string) => void;
  onSubmit: () => void;
  onClear: () => void;
}) => (
  <View style={styles.searchContainer}>
    <Ionicons name="search" size={20} color="#AAAAAA" style={styles.searchIcon} />
    <TextInput
      style={styles.searchInput}
      placeholder="Buscar por nome ou matrícula..."
      placeholderTextColor="#777"
      value={searchText}
      onChangeText={onChangeText}
      onSubmitEditing={onSubmit}
      returnKeyType="search"
    />
    {searchText.length > 0 && (
      <TouchableOpacity
        style={styles.clearButton}
        onPress={onClear}
      >
        <Ionicons name="close-circle" size={20} color="#AAAAAA" />
      </TouchableOpacity>
    )}
    <TouchableOpacity
      style={styles.searchButton}
      onPress={onSubmit}
      activeOpacity={0.7}
    >
      <Ionicons name="search" size={20} color="#000" />
    </TouchableOpacity>
  </View>
));
export default function PendentesScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const [pagamentosPendentes, setPagamentosPendentes] = useState<PagamentoPendente[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [displayCount, setDisplayCount] = useState(0);
  const [totalPendentes, setTotalPendentes] = useState(0);
  const [currentPage, setCurrentPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);
  const [isSearching, setIsSearching] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [pagamentoSelecionado, setPagamentoSelecionado] = useState<PagamentoPendente | null>(null);
  const [processando, setProcessando] = useState(false);
  const [statusFilter, setStatusFilter] = useState<'todos' | 'pendente' | 'atrasado'>('todos');
  
  // Filtro de mês/ano
  const [mesAnoFilter, setMesAnoFilter] = useState<string>(''); // formato: YYYY-MM ou vazio para todos
  const [showMonthPicker, setShowMonthPicker] = useState(false);
  
  const PAGE_SIZE = 200;
  
  // Gerar lista de meses disponíveis (últimos 12 meses)
  const gerarMesesDisponiveis = () => {
    const meses = [];
    const hoje = new Date();
    for (let i = 0; i < 12; i++) {
      const data = new Date(hoje.getFullYear(), hoje.getMonth() - i, 1);
      const ano = data.getFullYear();
      const mes = String(data.getMonth() + 1).padStart(2, '0');
      const mesNome = data.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });
      meses.push({
        valor: `${ano}-${mes}`,
        label: mesNome.charAt(0).toUpperCase() + mesNome.slice(1)
      });
    }
    return meses;
  };
  
  const mesesDisponiveis = gerarMesesDisponiveis();
  
  useEffect(() => {
    setCurrentPage(0);
    setHasMore(true);
    fetchTotal();
    fetchPendentes(0);
  }, [statusFilter, mesAnoFilter]);
  const fetchTotal = async (nome?: string) => {
    try {
      const filterParam = statusFilter === 'todos' ? '' : `&status_filter=${statusFilter}`;
      const mesParam = mesAnoFilter ? `&mes=${mesAnoFilter}` : '';
      const url = nome
        ? `${API_URL}/pagamentos/pendentes-atrasados/count?nome=${encodeURIComponent(nome)}${filterParam}${mesParam}`
        : `${API_URL}/pagamentos/pendentes-atrasados/count?${filterParam}${mesParam}`;
      const response = await axios.get(url);
      setTotalPendentes(response.data.total);
    } catch (error) {
      devError("Erro ao buscar total:", error);
    }
  };
  
  const fetchPendentes = async (page: number, nome?: string, append: boolean = false) => {
    try {
      if (!append) {
        setLoading(true);
      } else {
        setLoadingMore(true);
      }
      const skip = page * PAGE_SIZE;
      const filterParam = statusFilter === 'todos' ? '' : `&status_filter=${statusFilter}`;
      const mesParam = mesAnoFilter ? `&mes=${mesAnoFilter}` : '';
      const url = nome
        ? `${API_URL}/pagamentos/pendentes-atrasados?skip=${skip}&limit=${PAGE_SIZE}&nome=${encodeURIComponent(nome)}${filterParam}${mesParam}`
        : `${API_URL}/pagamentos/pendentes-atrasados?skip=${skip}&limit=${PAGE_SIZE}${filterParam}${mesParam}`;
      const response = await axios.get(url);
      const novosPendentes = response.data;
      if (append) {
        setPagamentosPendentes(prev => [...prev, ...novosPendentes]);
      } else {
        setPagamentosPendentes(novosPendentes);
        setDisplayCount(novosPendentes.length);
      }
      setHasMore(novosPendentes.length === PAGE_SIZE);
    } catch (error) {
      devError("Erro ao buscar pendentes:", error);
    } finally {
      setLoading(false);
      setLoadingMore(false);
    }
  };
  const handleSearch = () => {
    if (searchText.trim() === '') {
      setIsSearching(false);
      setCurrentPage(0);
      setHasMore(true);
      fetchTotal();
      fetchPendentes(0);
    } else {
      setIsSearching(true);
      setCurrentPage(0);
      setHasMore(true);
      fetchTotal(searchText);
      fetchPendentes(0, searchText);
    }
  };
  const handleClearSearch = () => {
    setSearchText('');
    setIsSearching(false);
    setCurrentPage(0);
    setHasMore(true);
    fetchTotal();
    fetchPendentes(0);
  };
  const handleLoadMore = () => {
    if (!loadingMore && hasMore) {
      const nextPage = currentPage + 1;
      setCurrentPage(nextPage);
      const searchTerm = isSearching ? searchText : undefined;
      fetchPendentes(nextPage, searchTerm, true);
    }
  };
  const handleNavigate = (matricula: string) => {
    router.push(`/${matricula}`);
  };
  const handlePagarPagamento = (idPagamento: number, alunoNome: string) => {
    devLog('handlePagarPagamento chamado', { idPagamento, alunoNome });
    const pagamento = pagamentosPendentes.find(p => p.id_pagamento === idPagamento);
    if (!pagamento) {
      devError('Pagamento não encontrado na lista local');
      return;
    }
    devLog('Pagamento encontrado:', pagamento);
    setPagamentoSelecionado(pagamento);
    setModalVisible(true);
  };
  const confirmarPagamento = async (idPagamento: number, pagamento: PagamentoPendente) => {
    setProcessando(true);
    try {
      devLog('Confirmando pagamento...');
      const dataAtual = new Date().toISOString().split('T')[0];
      const payload = {
        data_pagamento: dataAtual,
        valor_total_pago: pagamento.valor_total_devido.toString(),
        status: 'pago'
      };
      devLog('URL:', `${API_URL}/pagamentos/${idPagamento}/pagar`);
      devLog('Payload:', payload);
      const response = await axios.put(
        `${API_URL}/pagamentos/${idPagamento}/pagar`,
        payload,
        {
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );
      devLog('Resposta recebida:', response.data);
      devLog('Status HTTP:', response.status);
      if (response.status !== 200) {
        throw new Error(`Status inesperado: ${response.status}`);
      }
      if (response.data.status !== 'pago') {
        throw new Error(`Pagamento não foi marcado como pago: ${response.data.status}`);
      }
      setPagamentosPendentes(prev => prev.filter(p => p.id_pagamento !== idPagamento));
      setTotalPendentes(prev => Math.max(0, prev - 1));
      setDisplayCount(prev => Math.max(0, prev - 1));
      devLog('Pagamento removido da lista local');
      setModalVisible(false);
      setPagamentoSelecionado(null);
    } catch (error: any) {
      devError('ERRO AO CONFIRMAR PAGAMENTO');
      devError('Tipo do erro:', error.constructor?.name || 'Desconhecido');
      let mensagemErro = 'Não foi possível confirmar o pagamento';
      if (error.response) {
        devError('Resposta do servidor:', error.response.data);
        devError('Status HTTP:', error.response.status);
        if (error.response.data?.detail) {
          mensagemErro = error.response.data.detail;
        } else if (typeof error.response.data === 'string') {
          mensagemErro = error.response.data;
        }
      } else if (error.request) {
        devError('Sem resposta do servidor');
        mensagemErro = 'Servidor não respondeu. Verifique sua conexão.';
      } else {
        devError('Erro:', error.message);
        mensagemErro = error.message;
      }
      alert(mensagemErro);
    } finally {
      setProcessando(false);
    }
  };
  const renderItem = ({ item }: { item: PagamentoPendente }) => (
    <PagamentoCard item={item} onPress={handleNavigate} onPagar={handlePagarPagamento} />
  );
  const keyExtractor = (item: PagamentoPendente) => item.id_pagamento.toString();
  if (loading) {
    return (
      <View style={[styles.container, { justifyContent: 'center' }]}>
        <ActivityIndicator size="large" color="#FFD700" />
      </View>
    );
  }
  const isWeb = Platform.OS === 'web';
  return (
    <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>
      <View style={[styles.contentWrapper, isWeb && styles.contentWrapperWeb]}>
        <View style={styles.header}>
          <Text style={styles.title}>Pagamentos Pendentes</Text>
          <Text style={styles.subtitle}>
            {isSearching
              ? `${displayCount} de ${totalPendentes} pagamento(s)`
              : `${totalPendentes} pagamento(s) ${statusFilter === 'todos' ? 'pendente(s)/atrasado(s)' : statusFilter === 'atrasado' ? 'atrasado(s)' : 'pendente(s)'}`
            }
          </Text>
        </View>
        <SearchBar
          searchText={searchText}
          onChangeText={setSearchText}
          onSubmit={handleSearch}
          onClear={handleClearSearch}
        />
        {}
        <View style={styles.filterContainer}>
          <TouchableOpacity
            style={[styles.filterButton, statusFilter === 'todos' && styles.filterButtonActive]}
            onPress={() => setStatusFilter('todos')}
          >
            <Text style={[styles.filterButtonText, statusFilter === 'todos' && styles.filterButtonTextActive]}>
              Todos
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.filterButton, statusFilter === 'atrasado' && styles.filterButtonActive, statusFilter === 'atrasado' && { borderColor: '#B22222', backgroundColor: '#2A1A1A' }]}
            onPress={() => setStatusFilter('atrasado')}
          >
            <Text style={[styles.filterButtonText, statusFilter === 'atrasado' && styles.filterButtonTextActive]}>
              Atrasados
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.filterButton, statusFilter === 'pendente' && styles.filterButtonActive, statusFilter === 'pendente' && { borderColor: '#FF8C00', backgroundColor: '#2A2010' }]}
            onPress={() => setStatusFilter('pendente')}
          >
            <Text style={[styles.filterButtonText, statusFilter === 'pendente' && styles.filterButtonTextActive]}>
              Pendentes
            </Text>
          </TouchableOpacity>
        </View>
        
        {/* Filtro de Mês */}
        <View style={styles.monthFilterContainer}>
          <Text style={styles.monthFilterLabel}>Mês de vencimento:</Text>
          <TouchableOpacity
            style={styles.monthFilterButton}
            onPress={() => setShowMonthPicker(!showMonthPicker)}
          >
            <Ionicons name="calendar-outline" size={18} color="#FFD700" />
            <Text style={styles.monthFilterButtonText}>
              {mesAnoFilter
                ? mesesDisponiveis.find(m => m.valor === mesAnoFilter)?.label || 'Todos os meses'
                : 'Todos os meses'}
            </Text>
            <Ionicons name={showMonthPicker ? "chevron-up" : "chevron-down"} size={18} color="#FFD700" />
          </TouchableOpacity>
        </View>
        
        {/* Dropdown de Meses */}
        {showMonthPicker && (
          <View style={styles.monthPickerDropdown}>
            <TouchableOpacity
              style={[styles.monthOption, !mesAnoFilter && styles.monthOptionActive]}
              onPress={() => {
                setMesAnoFilter('');
                setShowMonthPicker(false);
              }}
            >
              <Text style={[styles.monthOptionText, !mesAnoFilter && styles.monthOptionTextActive]}>
                Todos os meses
              </Text>
            </TouchableOpacity>
            {mesesDisponiveis.map((mes) => (
              <TouchableOpacity
                key={mes.valor}
                style={[styles.monthOption, mesAnoFilter === mes.valor && styles.monthOptionActive]}
                onPress={() => {
                  setMesAnoFilter(mes.valor);
                  setShowMonthPicker(false);
                }}
              >
                <Text style={[styles.monthOptionText, mesAnoFilter === mes.valor && styles.monthOptionTextActive]}>
                  {mes.label}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        )}
        
      <FlatList
        data={pagamentosPendentes}
        keyExtractor={keyExtractor}
        renderItem={renderItem}
        onEndReached={handleLoadMore}
        onEndReachedThreshold={0.5}
        maxToRenderPerBatch={10}
        updateCellsBatchingPeriod={50}
        initialNumToRender={10}
        windowSize={5}
        removeClippedSubviews={true}
        ListFooterComponent={
          loadingMore ? (
            <View style={styles.loadingMore}>
              <ActivityIndicator size="small" color="#FFD700" />
              <Text style={styles.loadingMoreText}>Carregando mais...</Text>
            </View>
          ) : null
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Ionicons name="checkmark-circle" size={72} color="#2E8B57" />
            <Text style={styles.emptyText}>Nenhum pagamento atrasado!</Text>
            <Text style={styles.emptySubtext}>Todos os alunos estão em dia</Text>
          </View>
        }
        style={styles.list}
        contentContainerStyle={styles.listContent}
      />
      </View>
      {}
      <Modal
        visible={modalVisible}
        transparent={true}
        animationType="fade"
        onRequestClose={() => !processando && setModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Ionicons name="alert-circle" size={48} color="#FFD700" />
              <Text style={styles.modalTitle}>Confirmar Pagamento</Text>
            </View>
            {pagamentoSelecionado && (
              <View style={styles.modalBody}>
                <Text style={styles.modalText}>
                  Confirmar que <Text style={styles.modalTextBold}>{pagamentoSelecionado.aluno_nome}</Text> realizou o pagamento de:
                </Text>
                <Text style={styles.modalValor}>
                  {formatCurrency(Number(pagamentoSelecionado.valor_total_devido))}
                </Text>
                <Text style={styles.modalInfo}>
                  Vencimento: {formatDateBR(pagamentoSelecionado.data_vencimento)}
                </Text>
              </View>
            )}
            <View style={styles.modalActions}>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonCancel]}
                onPress={() => {
                  setModalVisible(false);
                  setPagamentoSelecionado(null);
                }}
                disabled={processando}
              >
                <Text style={styles.modalButtonTextCancel}>Cancelar</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonConfirm]}
                onPress={() => pagamentoSelecionado && confirmarPagamento(pagamentoSelecionado.id_pagamento, pagamentoSelecionado)}
                disabled={processando}
              >
                {processando ? (
                  <ActivityIndicator size="small" color="#FFFFFF" />
                ) : (
                  <Text style={styles.modalButtonTextConfirm}>Confirmar</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
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
  header: {
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: '800',
    color: '#FFD700',
    marginBottom: 8,
    letterSpacing: 0.5,
  },
  subtitle: {
    fontSize: 15,
    color: '#AAAAAA',
    fontWeight: '500',
    marginBottom: 16,
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
    gap: 10,
  },
  filterButton: {
    flex: 1,
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 10,
    backgroundColor: '#282828',
    borderWidth: 2,
    borderColor: '#3A3A3A',
    alignItems: 'center',
    justifyContent: 'center',
  },
  filterButtonActive: {
    backgroundColor: '#FFD700',
    borderColor: '#FFD700',
  },
  filterButtonText: {
    color: '#AAAAAA',
    fontSize: 14,
    fontWeight: '600',
    letterSpacing: 0.3,
  },
  filterButtonTextActive: {
    color: '#000000',
    fontWeight: '700',
  },
  list: {
    flex: 1
  },
  listContent: {
    paddingBottom: 24,
  },
  pagamentoCard: {
    backgroundColor: '#282828',
    borderLeftWidth: 5,
    borderLeftColor: '#B22222',
    borderRadius: 12,
    padding: 16,
    marginVertical: 6,
    marginHorizontal: 16,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
  },
  cardContent: {
    flex: 1,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 12,
    gap: 12,
  },
  alunoNome: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '700',
    flex: 1,
    letterSpacing: 0.3,
  },
  statusBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
    elevation: 2,
  },
  statusBadgeText: {
    color: '#FFFFFF',
    fontSize: 10,
    fontWeight: '800',
    letterSpacing: 0.5,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 16,
    gap: 12,
  },
  infoLeft: {
    flex: 1,
    gap: 8,
  },
  vencimentoText: {
    color: '#CCCCCC',
    fontSize: 14,
    fontWeight: '500',
  },
  atrasoTag: {
    backgroundColor: '#B22222',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 8,
    alignSelf: 'flex-start',
    elevation: 2,
  },
  atrasoText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 0.3,
  },
  valorText: {
    color: '#FFD700',
    fontSize: 22,
    fontWeight: '800',
    letterSpacing: 0.5,
  },
  actionsRow: {
    flexDirection: 'row',
    gap: 10,
    alignItems: 'center',
  },
  pagarButton: {
    flex: 1,
    backgroundColor: '#2E8B57',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderRadius: 10,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    elevation: 3,
    shadowColor: '#2E8B57',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.4,
    shadowRadius: 4,
  },
  pagarButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '700',
    letterSpacing: 0.3,
  },
  detailButton: {
    backgroundColor: '#FFD700',
    paddingHorizontal: 18,
    paddingVertical: 12,
    borderRadius: 10,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    elevation: 3,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.4,
    shadowRadius: 4,
  },
  detailButtonText: {
    color: '#000000',
    fontSize: 14,
    fontWeight: '700',
    letterSpacing: 0.3,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 120,
    paddingHorizontal: 40,
  },
  emptyText: {
    color: '#FFFFFF',
    fontSize: 22,
    fontWeight: '700',
    marginBottom: 10,
    textAlign: 'center',
    letterSpacing: 0.5,
    marginTop: 20,
  },
  emptySubtext: {
    color: '#AAAAAA',
    fontSize: 15,
    textAlign: 'center',
    lineHeight: 22,
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
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalContent: {
    backgroundColor: '#282828',
    borderRadius: 16,
    padding: 24,
    width: '100%',
    maxWidth: 400,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  modalHeader: {
    alignItems: 'center',
    marginBottom: 20,
  },
  modalTitle: {
    fontSize: 24,
    fontWeight: '700',
    color: '#FFFFFF',
    marginTop: 12,
    letterSpacing: 0.5,
  },
  modalBody: {
    marginBottom: 24,
  },
  modalText: {
    fontSize: 16,
    color: '#CCCCCC',
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 16,
  },
  modalTextBold: {
    fontWeight: '700',
    color: '#FFFFFF',
  },
  modalValor: {
    fontSize: 32,
    fontWeight: '800',
    color: '#FFD700',
    textAlign: 'center',
    marginBottom: 12,
    letterSpacing: 1,
  },
  modalInfo: {
    fontSize: 14,
    color: '#AAAAAA',
    textAlign: 'center',
  },
  modalActions: {
    flexDirection: 'row',
    gap: 12,
  },
  modalButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 2,
  },
  modalButtonCancel: {
    backgroundColor: '#3A3A3A',
  },
  modalButtonConfirm: {
    backgroundColor: '#2E8B57',
  },
  modalButtonTextCancel: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  modalButtonTextConfirm: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },
  monthFilterContainer: {
    paddingHorizontal: 20,
    paddingVertical: 12,
    backgroundColor: '#1A1A1A',
    borderBottomWidth: 1,
    borderBottomColor: '#2A2A2A',
  },
  monthFilterLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#AAAAAA',
    marginBottom: 8,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  monthFilterButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#282828',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    gap: 10,
  },
  monthFilterButtonText: {
    flex: 1,
    fontSize: 15,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  monthPickerDropdown: {
    backgroundColor: '#1F1F1F',
    marginHorizontal: 20,
    marginTop: -8,
    marginBottom: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    maxHeight: 300,
    overflow: 'scroll',
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  monthOption: {
    paddingVertical: 14,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#2A2A2A',
  },
  monthOptionActive: {
    backgroundColor: '#2A2A0A',
    borderLeftWidth: 3,
    borderLeftColor: '#FFD700',
  },
  monthOptionText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#CCCCCC',
  },
  monthOptionTextActive: {
    color: '#FFD700',
    fontWeight: '700',
  },
});
