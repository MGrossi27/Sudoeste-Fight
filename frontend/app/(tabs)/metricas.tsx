import { Ionicons } from '@expo/vector-icons';
import axios from 'axios';
import { useFocusEffect } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useCallback, useState } from 'react';
import { ActivityIndicator, Dimensions, SafeAreaView, ScrollView, StyleSheet, Text, TouchableOpacity, View, Modal } from 'react-native';
import { LineChart, PieChart } from 'react-native-chart-kit';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { API_URL } from '../../config/api';
import { devError, devLog, formatCurrency, formatPercent } from '../../utils/helpers';
const screenWidth = Dimensions.get('window').width;
interface KPIs {
  total_alunos: number;
  alunos_ativos: number;
  taxa_retencao: number;
  receita_total: number;
  mrr: number;
  ticket_medio: number;
  taxa_churn: number;
  taxa_conversao_pagamentos: number;
  total_pagamentos: number;
  total_itens_pagamento: number;
  total_inscricoes: number;
}
interface ReceitaMensal {
  mes: string;
  receita: number;
  quantidade_pagamentos: number;
  ticket_medio: number;
}
interface DistribuicaoPlanos {
  categorias: string[];
  valores: number[];
  percentuais: number[];
  titulo: string;
}
interface TaxaInadimplencia {
  taxa_inadimplencia: number;
  quantidade_atrasados: number;
  valor_em_atraso: number;
  total_pagamentos: number;
}
interface PagamentosMensais {
  mes: string;
  total_alunos: number;
  alunos_pagaram: number;
  alunos_nao_pagaram: number;
  percentual_pagaram: number;
  percentual_nao_pagaram: number;
}

interface PagamentoMesAnterior {
  mes_origem: string;
  quantidade: number;
  valor: number;
}

interface DetalhePagamentoMensal {
  mes: string;
  receita_total: number;
  total_pagamentos_recebidos: number;
  pagamentos_do_mes_total: number;
  pagamentos_do_mes_no_prazo: number;
  pagamentos_do_mes_apos_prazo_neste_mes: number;
  pagamentos_do_mes_atrasados_posteriores: number;
  pagamentos_do_mes_pendentes: number;
  valor_pagamentos_do_mes: number;
  percentual_no_prazo: number;
  percentual_apos_prazo_neste_mes: number;
  percentual_atrasados_posteriores: number;
  percentual_pendentes: number;
  pagamentos_meses_anteriores: PagamentoMesAnterior[];
  valor_meses_anteriores: number;
}
export default function MetricasScreen() {
  const insets = useSafeAreaInsets();
  const [loading, setLoading] = useState(true);
  const [kpis, setKpis] = useState<KPIs | null>(null);
  const [receitaMensal, setReceitaMensal] = useState<ReceitaMensal[]>([]);
  const [distribuicaoPlanos, setDistribuicaoPlanos] = useState<DistribuicaoPlanos | null>(null);
  const [modalidadesPopulares, setModalidadesPopulares] = useState<DistribuicaoPlanos | null>(null);
  const [taxaInadimplencia, setTaxaInadimplencia] = useState<TaxaInadimplencia | null>(null);
  const [selectedPoint, setSelectedPoint] = useState<{ index: number; value: number } | null>(null);
  const [pagamentosMensais, setPagamentosMensais] = useState<PagamentosMensais[]>([]);
  const [detalheMesModal, setDetalheMesModal] = useState(false);
  const [detalheMesSelecionado, setDetalheMesSelecionado] = useState<DetalhePagamentoMensal | null>(null);
  const [loadingDetalhe, setLoadingDetalhe] = useState(false);
  useFocusEffect(
    useCallback(() => {
      loadDashboardData();
    }, [])
  );
  const loadDashboardData = async () => {
    try {
      setLoading(true);
      devLog("=== CARREGANDO DASHBOARD ===");

      const [kpisRes, receitaRes, planosRes, modalidadesRes, inadimplenciaRes, pagamentosRes] = await Promise.all([
        axios.get(`${API_URL}/metricas/kpis`),
        axios.get(`${API_URL}/metricas/receita-mensal?meses=12`),
        axios.get(`${API_URL}/metricas/distribuicao-planos`),
        axios.get(`${API_URL}/metricas/modalidades-populares`),
        axios.get(`${API_URL}/metricas/taxa-inadimplencia`),
        axios.get(`${API_URL}/metricas/pagamentos-mensais?meses=12`)
      ]);
      setKpis(kpisRes.data);
      setReceitaMensal(receitaRes.data);
      setDistribuicaoPlanos(planosRes.data);
      setModalidadesPopulares(modalidadesRes.data);
      setTaxaInadimplencia(inadimplenciaRes.data);
      setPagamentosMensais(pagamentosRes.data);
      devLog("Dashboard carregado com sucesso!");
      devLog("Receita mensal - Total de meses:", receitaRes.data.length);
      devLog("Primeiro mês:", receitaRes.data[0]?.mes);
      devLog("Último mês:", receitaRes.data[receitaRes.data.length - 1]?.mes);
    } catch (error) {
      devError('Erro ao carregar dashboard:', error);
    } finally {
      setLoading(false);
    }
  };
  
  const carregarDetalheMes = async (mes: string) => {
    try {
      devLog(`Carregando detalhes do mês: ${mes}`);
      setLoadingDetalhe(true);
      const response = await axios.get(`${API_URL}/metricas/detalhes-pagamento-mes/${mes}`);
      devLog('Resposta recebida:', response.data);
      setDetalheMesSelecionado(response.data);
      setDetalheMesModal(true);
    } catch (error) {
      devError('Erro ao carregar detalhes do mês:', error);
    } finally {
      setLoadingDetalhe(false);
    }
  };
  
  if (loading) {
    return (
      <View style={[styles.container, { justifyContent: 'center', paddingTop: insets.top }]}>
        <ActivityIndicator size="large" color="#FFD700" />
        <Text style={styles.loadingText}>Carregando métricas...</Text>
      </View>
    );
  }
  
  const ultimosDozeReceitaMensal = receitaMensal.slice(-12);
  devLog("Meses no gráfico:", ultimosDozeReceitaMensal.length, ultimosDozeReceitaMensal.map(r => r.mes));
  
  const receitaChartData = {
    labels: ultimosDozeReceitaMensal.map(r => {
      const [ano, mes] = r.mes.split('-');
      const meses = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
      return `${meses[parseInt(mes) - 1]}/${ano.slice(2)}`;
    }),
    datasets: [{
      data: ultimosDozeReceitaMensal.map(r => Number(r.receita) / 1000),
      color: (opacity = 1) => `rgba(255, 215, 0, ${opacity})`
    }]
  };
  return (
    <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Text style={styles.title}>Painel de Análises</Text>
          <Text style={styles.subtitle}>Métricas Estratégicas em Tempo Real</Text>
        </View>
        {kpis && (
          <View style={styles.kpiSection}>
            <Text style={styles.sectionTitle}>Indicadores Principais</Text>
            <View style={styles.kpiGrid}>
              <View style={styles.kpiCard}>
                <View style={styles.kpiHeader}>
                  <Ionicons name="people" size={20} color="#FFD700" />
                  <Text style={styles.kpiLabel}>Alunos Ativos</Text>
                </View>
                <Text style={styles.kpiValue}>{kpis.alunos_ativos}</Text>
                <Text style={styles.kpiSubtext}>de {kpis.total_alunos} total</Text>
              </View>
              <View style={styles.kpiCard}>
                <View style={styles.kpiHeader}>
                  <Ionicons name="trending-up" size={20} color="#FFD700" />
                  <Text style={styles.kpiLabel}>Receita Mensal</Text>
                </View>
                <Text style={styles.kpiValue}>{formatCurrency(kpis.mrr / 1000)}k</Text>
                <Text style={styles.kpiSubtext}>Mensalidades Ativas</Text>
              </View>
              <View style={styles.kpiCard}>
                <View style={styles.kpiHeader}>
                  <Ionicons name="checkmark-circle" size={20} color="#FFD700" />
                  <Text style={styles.kpiLabel}>Taxa Retenção</Text>
                </View>
                <Text style={styles.kpiValue}>{formatPercent(kpis.taxa_retencao)}</Text>
                <Text style={styles.kpiSubtext}>Churn 30d: {formatPercent(kpis.taxa_churn)}</Text>
              </View>
              <View style={styles.kpiCard}>
                <View style={styles.kpiHeader}>
                  <Ionicons name="cash" size={20} color="#FFD700" />
                  <Text style={styles.kpiLabel}>Ticket Médio</Text>
                </View>
                <Text style={styles.kpiValue}>{formatCurrency(kpis.ticket_medio)}</Text>
                <Text style={styles.kpiSubtext}>por pagamento</Text>
              </View>
            </View>
          </View>
        )}
        {}
        {receitaMensal.length > 0 && (
          <View style={styles.chartCard}>
            <View style={styles.chartHeader}>
              <View>
                <Text style={styles.chartTitle}>Evolução da Receita</Text>
                <Text style={styles.chartSubtitle}>Últimos 12 meses</Text>
              </View>
              {(() => {
                const dados = receitaMensal.slice(-12);
                if (dados.length >= 7) {
                  const ultimoMesCompleto = dados[dados.length - 2];
                  const penultimoMes = dados[dados.length - 3];
                  
                  const ultimoMesReceita = Number(ultimoMesCompleto.receita);
                  const penultimoMesReceita = Number(penultimoMes.receita);
                  const mediaUltimo = ultimoMesReceita > (penultimoMesReceita * 0.3);
                  
                  const dadosCompletos = mediaUltimo ? dados.slice(0, -1) : dados;
                  
                  const trim1 = dadosCompletos.slice(-3);
                  const trim2 = dadosCompletos.slice(-6, -3);
                  
                  const mediaTrim1 = trim1.reduce((acc, m) => acc + Number(m.receita), 0) / trim1.length;
                  const mediaTrim2 = trim2.reduce((acc, m) => acc + Number(m.receita), 0) / trim2.length;
                  
                  const variacaoTrimestral = ((mediaTrim1 - mediaTrim2) / mediaTrim2) * 100;
                  
                  const primeiraReceita = Number(dadosCompletos[0].receita);
                  const ultimaReceita = Number(dadosCompletos[dadosCompletos.length - 1].receita);
                  const variacaoAnual = ((ultimaReceita - primeiraReceita) / primeiraReceita) * 100;
                  
                  const isPositivo = variacaoTrimestral >= 0;
                  
                  return (
                    <View style={[styles.chartBadge, { backgroundColor: isPositivo ? '#FFD700' : '#DC143C' }]}>
                      <View style={styles.badgeContent}>
                        <Ionicons name={isPositivo ? "arrow-up" : "arrow-down"} size={16} color="#121212" />
                        <View>
                          <Text style={styles.chartBadgeText}>{isPositivo ? '+' : ''}{variacaoTrimestral.toFixed(1)}%</Text>
                          <Text style={styles.chartBadgeSubtext}>{variacaoAnual.toFixed(1)}% anual</Text>
                        </View>
                      </View>
                    </View>
                  );
                }
                return null;
              })()}
            </View>
            {selectedPoint && (
              <View style={styles.detailsContainer}>
                <View style={styles.tooltipContainer}>
                  <Text style={styles.tooltipText}>
                    {(() => {
                      const mesAno = receitaMensal.slice(-12)[selectedPoint.index].mes;
                      const [ano, mes] = mesAno.split('-');
                      const mesNome = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
                                      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'][parseInt(mes) - 1];
                      const valor = selectedPoint.value * 1000;
                      return `${mesNome} ${ano} - R$ ${valor.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
                    })()}
                  </Text>
                  <TouchableOpacity
                    style={styles.infoButton}
                    onPress={() => {
                      const mesClicado = receitaMensal.slice(-12)[selectedPoint.index].mes;
                      carregarDetalheMes(mesClicado);
                    }}
                  >
                    <Text style={styles.infoButtonText}>Ver Detalhes</Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={styles.closeButton}
                    onPress={() => setSelectedPoint(null)}
                  >
                    <Ionicons name="close-circle" size={26} color="#FFD700" />
                  </TouchableOpacity>
                </View>
                {(() => {
                  const mesClicado = receitaMensal.slice(-12)[selectedPoint.index].mes;
                  const dadosMes = pagamentosMensais.find(p => p.mes === mesClicado);
                  if (!dadosMes) {
                    return (
                      <View style={styles.noDataContainer}>
                        <Text style={styles.noDataText}>Sem dados de pagamento para este mês</Text>
                      </View>
                    );
                  }
                  if (dadosMes.alunos_pagaram === 0 && dadosMes.alunos_nao_pagaram === 0) {
                    return (
                      <View style={styles.noDataContainer}>
                        <Text style={styles.noDataText}>Sem dados</Text>
                      </View>
                    );
                  }
                  return (
                    <View style={styles.pieChartContainer}>
                      <Text style={styles.pieChartTitle}>Status Financeiro dos Alunos</Text>
                      <Text style={styles.pieChartSubtitle}>
                        Situação de pagamentos no final deste mês
                      </Text>
                      
                      <PieChart
                        data={[
                          {
                            name: 'Em Dia',
                            population: dadosMes.alunos_pagaram,
                            color: '#10b981',
                            legendFontColor: '#FFFFFF',
                            legendFontSize: 14
                          },
                          {
                            name: 'Inadimplentes',
                            population: dadosMes.alunos_nao_pagaram,
                            color: '#ef4444',
                            legendFontColor: '#FFFFFF',
                            legendFontSize: 14
                          }
                        ]}
                        width={screenWidth - 92}
                        height={200}
                        chartConfig={{
                          color: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
                          labelColor: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
                        }}
                        accessor="population"
                        backgroundColor="transparent"
                        paddingLeft="15"
                        absolute
                      />
                      <View style={styles.pieStats}>
                        <View style={styles.pieStat}>
                          <View style={[styles.pieStatDot, { backgroundColor: '#10b981' }]} />
                          <View>
                            <Text style={styles.pieStatLabel}>Alunos em Dia</Text>
                            <Text style={styles.pieStatValue}>
                              {dadosMes.alunos_pagaram} alunos
                              <Text style={styles.pieStatPercent}>
                                {' '}({dadosMes.percentual_pagaram.toFixed(1)}%)
                              </Text>
                            </Text>
                          </View>
                        </View>
                        <View style={styles.pieStat}>
                          <View style={[styles.pieStatDot, { backgroundColor: '#ef4444' }]} />
                          <View>
                            <Text style={styles.pieStatLabel}>Alunos Inadimplentes</Text>
                            <Text style={styles.pieStatValue}>
                              {dadosMes.alunos_nao_pagaram} alunos
                              <Text style={styles.pieStatPercent}>
                                {' '}({dadosMes.percentual_nao_pagaram.toFixed(1)}%)
                              </Text>
                            </Text>
                          </View>
                        </View>
                        <View style={styles.pieTotal}>
                          <Text style={styles.pieTotalLabel}>Total de Alunos Ativos</Text>
                          <Text style={styles.pieTotalValue}>
                            {dadosMes.total_alunos}
                          </Text>
                        </View>
                      </View>
                    </View>
                  );
                })()}
              </View>
            )}
            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ paddingRight: 36 }}>
              <LineChart
                data={receitaChartData}
                width={Math.max(screenWidth - 72, receitaChartData.labels.length * 60)}
                height={220}
                yAxisLabel=""
                yAxisSuffix=""
                chartConfig={{
                  backgroundColor: '#282828',
                  backgroundGradientFrom: '#282828',
                  backgroundGradientTo: '#1A1A1A',
                  decimalPlaces: 0,
                  color: (opacity = 1) => `rgba(255, 215, 0, ${opacity})`,
                  labelColor: (opacity = 1) => `rgba(170, 170, 170, ${opacity})`,
                  style: { borderRadius: 12 },
                  propsForDots: {
                    r: '5',
                    strokeWidth: '2',
                    stroke: '#FFD700',
                    fill: '#282828'
                  },
                  propsForBackgroundLines: {
                    strokeDasharray: '',
                    stroke: '#3A3A3A',
                    strokeWidth: 1
                  },
                  propsForLabels: {
                    fontSize: 10
                  }
                }}
                bezier
                style={styles.chart}
                withInnerLines
                withOuterLines
                withVerticalLines={false}
                withDots={true}
                withShadow={false}
                formatYLabel={(value) => `${Math.round(parseFloat(value))}k`}
                decorator={() => null}
                onDataPointClick={(data) => {
                  if (selectedPoint?.index === data.index) {
                    setSelectedPoint(null);
                  } else {
                    setSelectedPoint({ index: data.index, value: data.value });
                  }
                }}
              />
            </ScrollView>
            <Text style={styles.chartFootnote}>* Toque nos pontos para ver detalhes • Valores em milhares (ex: 120k = R$ 120.000) • Arraste para ver todos os meses</Text>
          </View>
        )}
        {}
        {modalidadesPopulares && (
          <View style={styles.listCard}>
            <View style={styles.listHeader}>
              <Ionicons name="barbell" size={24} color="#FFD700" />
              <Text style={styles.listTitle}>Ranking de Modalidades</Text>
            </View>
            <Text style={styles.listSubtitle}>Popularidade entre os alunos</Text>
            {modalidadesPopulares.categorias.map((modalidade, index) => {
              const percentage = modalidadesPopulares.percentuais[index];
              const quantidade = modalidadesPopulares.valores[index];
              const getRankingColor = (position: number) => {
                if (position === 0) return '#FFD700';
                if (position === 1) return '#C0C0C0';
                if (position === 2) return '#CD7F32';
                return '#AAAAAA';
              };
              return (
                <View key={index} style={styles.listItem}>
                  <View style={styles.listItemLeft}>
                    <View style={[styles.listRank, index < 3 && styles.listRankFirst]}>
                      <Text style={[styles.listRankText, index < 3 && styles.listRankTextFirst]}>#{index + 1}</Text>
                    </View>
                    <View>
                      <Text style={styles.listItemName}>{modalidade}</Text>
                      <Text style={styles.listItemValue}>{quantidade} alunos</Text>
                    </View>
                  </View>
                  <View style={styles.listItemRight}>
                    <View style={styles.progressBar}>
                      <View
                        style={[
                          styles.progressFill,
                          {
                            width: `${percentage}%`,
                            backgroundColor: getRankingColor(index)
                          }
                        ]}
                      />
                    </View>
                    <Text style={styles.listItemPercent}>{percentage}%</Text>
                  </View>
                </View>
              );
            })}
          </View>
        )}
        {}
        {distribuicaoPlanos && (
          <View style={styles.chartCard}>
            <View style={styles.chartHeader}>
              <View>
                <View style={styles.listHeader}>
                  <Ionicons name="pricetags" size={24} color="#FFD700" />
                  <Text style={styles.listTitle}>Distribuição de Planos</Text>
                </View>
                <Text style={styles.listSubtitle}>Inscrições ativas por plano</Text>
              </View>
            </View>
            {}
            <PieChart
              data={distribuicaoPlanos.categorias.map((plano, index) => {
                const getPlanoColor = (nomePlano: string) => {
                  if (nomePlano.includes('Premium')) return '#FFD700';
                  if (nomePlano.includes('Light')) return '#87CEEB';
                  if (nomePlano.includes('Starter')) return '#90EE90';
                  if (nomePlano.includes('Fighter')) return '#DC143C';
                  return '#FFD700';
                };
                return {
                  name: plano,
                  population: distribuicaoPlanos.valores[index],
                  color: getPlanoColor(plano),
                  legendFontColor: '#FFFFFF',
                  legendFontSize: 14
                };
              })}
              width={screenWidth - 72}
              height={220}
              chartConfig={{
                color: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
                labelColor: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
              }}
              accessor="population"
              backgroundColor="transparent"
              paddingLeft="15"
              absolute
            />
            {}
            <View style={styles.pieStats}>
              {distribuicaoPlanos.categorias.map((plano, index) => {
                const percentage = distribuicaoPlanos.percentuais[index];
                const quantidade = distribuicaoPlanos.valores[index];
                const getPlanoColor = (nomePlano: string) => {
                  if (nomePlano.includes('Premium')) return '#FFD700';
                  if (nomePlano.includes('Light')) return '#87CEEB';
                  if (nomePlano.includes('Starter')) return '#90EE90';
                  if (nomePlano.includes('Fighter')) return '#DC143C';
                  return '#FFD700';
                };
                return (
                  <View key={`plano-stat-${index}`} style={styles.pieStat}>
                    <View style={[styles.pieStatDot, { backgroundColor: getPlanoColor(plano) }]} />
                    <View>
                      <Text style={styles.pieStatLabel}>{plano}</Text>
                      <Text style={styles.pieStatValue}>
                        {quantidade} alunos
                        <Text style={styles.pieStatPercent}>
                          {' '}({percentage.toFixed(1)}%)
                        </Text>
                      </Text>
                    </View>
                  </View>
                );
              })}
            </View>
          </View>
        )}
        {}
        {taxaInadimplencia && (
          <View style={[styles.alertCard, {
            borderLeftColor: taxaInadimplencia.taxa_inadimplencia > 10 ? '#B22222' : taxaInadimplencia.taxa_inadimplencia > 5 ? '#FFD700' : '#10b981'
          }]}>
            <View style={styles.alertHeader}>
              <Ionicons
                name={taxaInadimplencia.taxa_inadimplencia > 10 ? "warning" : "shield-checkmark"}
                size={28}
                color={taxaInadimplencia.taxa_inadimplencia > 10 ? '#B22222' : taxaInadimplencia.taxa_inadimplencia > 5 ? '#FFD700' : '#10b981'}
              />
              <View style={styles.alertHeaderText}>
                <Text style={styles.alertTitle}>Taxa de Inadimplência</Text>
                <Text style={[styles.alertValue, {
                  color: taxaInadimplencia.taxa_inadimplencia > 10 ? '#B22222' : taxaInadimplencia.taxa_inadimplencia > 5 ? '#FFD700' : '#10b981'
                }]}>
                  {formatPercent(taxaInadimplencia.taxa_inadimplencia)}
                </Text>
              </View>
            </View>
            <View style={styles.alertStats}>
              <View style={styles.alertStat}>
                <Text style={styles.alertStatLabel}>Atrasados</Text>
                <Text style={styles.alertStatValue}>{taxaInadimplencia.quantidade_atrasados}</Text>
              </View>
              <View style={styles.alertStat}>
                <Text style={styles.alertStatLabel}>Valor em Atraso</Text>
                <Text style={[styles.alertStatValue, { color: '#B22222' }]}>
                  {formatCurrency(taxaInadimplencia.valor_em_atraso)}
                </Text>
              </View>
              <View style={styles.alertStat}>
                <Text style={styles.alertStatLabel}>Total</Text>
                <Text style={styles.alertStatValue}>{taxaInadimplencia.total_pagamentos}</Text>
              </View>
            </View>
            <Text style={styles.alertInsight}>
              {taxaInadimplencia.taxa_inadimplencia < 5
                ? 'Excelente controle de inadimplência!'
                : taxaInadimplencia.taxa_inadimplencia < 10
                ? 'Atenção: monitorar pagamentos atrasados'
                : 'Crítico: implementar cobrança ativa urgente'}
            </Text>
          </View>
        )}
        {}
        {kpis && (
          <View style={styles.summaryCard}>
            <Text style={styles.summaryTitle}>Resumo Executivo</Text>
            <View style={styles.summaryGrid}>
              <View style={styles.summaryItem}>
                <Text style={styles.summaryLabel}>Receita Total</Text>
                <Text style={styles.summaryValue}>{formatCurrency(Number(kpis.receita_total))}</Text>
              </View>
              <View style={styles.summaryItem}>
                <Text style={styles.summaryLabel}>Taxa Adimplência</Text>
                <Text style={styles.summaryValue}>{formatPercent(kpis.taxa_conversao_pagamentos)}</Text>
              </View>
              <View style={styles.summaryItem}>
                <Text style={styles.summaryLabel}>Receita/Aluno</Text>
                <Text style={styles.summaryValue}>
                  {formatCurrency(kpis.mrr / kpis.alunos_ativos)}
                </Text>
              </View>
              <View style={styles.summaryItem}>
                <Text style={styles.summaryLabel}>Status Geral</Text>
                <Text style={[styles.summaryValue, { color: (() => {
                  const retencao = kpis.taxa_retencao;
                  const churn = kpis.taxa_churn;
                  const adimplencia = kpis.taxa_conversao_pagamentos;
                  
                  if (retencao > 85 && churn < 5 && adimplencia > 90) {
                    return '#10b981';
                  }
                  if (retencao > 75 && churn < 10 && adimplencia > 80) {
                    return '#FFD700';
                  }
                  if (retencao > 60 && churn < 15 && adimplencia > 70) {
                    return '#f59e0b';
                  }
                  return '#ef4444';
                })() }]}>
                  {(() => {
                    const retencao = kpis.taxa_retencao;
                    const churn = kpis.taxa_churn;
                    const adimplencia = kpis.taxa_conversao_pagamentos;
                    
                    if (retencao > 85 && churn < 5 && adimplencia > 90) {
                      return 'Excelente';
                    }
                    if (retencao > 75 && churn < 10 && adimplencia > 80) {
                      return 'Bom';
                    }
                    if (retencao > 60 && churn < 15 && adimplencia > 70) {
                      return 'Atenção';
                    }
                    return 'Crítico';
                  })()}
                </Text>
              </View>
            </View>
          </View>
        )}
      </ScrollView>
      
      {/* Modal de Detalhes do Mês */}
      <Modal
        visible={detalheMesModal}
        transparent={true}
        animationType="fade"
        onRequestClose={() => setDetalheMesModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalDetalheMesContent}>
            {loadingDetalhe ? (
              <ActivityIndicator size="large" color="#FFD700" />
            ) : detalheMesSelecionado ? (
              <>
                <View style={styles.modalDetalheMesHeader}>
                  <Text style={styles.modalDetalheMesTitle}>
                    Detalhes de {(() => {
                      const [ano, mes] = detalheMesSelecionado.mes.split('-');
                      const mesNome = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
                                      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'][parseInt(mes) - 1];
                      return `${mesNome}/${ano}`;
                    })()}
                  </Text>
                  <TouchableOpacity onPress={() => setDetalheMesModal(false)}>
                    <Ionicons name="close" size={28} color="#FFFFFF" />
                  </TouchableOpacity>
                </View>
                
                <ScrollView style={styles.modalDetalheMesBody}>
                  {/* Receita Total */}
                  <View style={styles.detalheMesCard}>
                    <Text style={styles.detalheMesCardTitle}>Receita Total Recebida</Text>
                    <Text style={styles.detalheMesValorPrincipal}>
                      {formatCurrency(detalheMesSelecionado.receita_total)}
                    </Text>
                    <Text style={styles.detalheMesSubtext}>
                      {detalheMesSelecionado.total_pagamentos_recebidos} pagamentos recebidos neste mês
                    </Text>
                  </View>
                  
                  {/* Pagamentos do Próprio Mês */}
                  <View style={styles.detalheMesCard}>
                    <Text style={styles.detalheMesCardTitle}>Pagamentos Referentes a Este Mês</Text>
                    <Text style={styles.detalheMesSubtext}>
                      Total esperado: {detalheMesSelecionado.pagamentos_do_mes_total} pagamentos
                    </Text>
                    
                    {/* Barra de progresso multi-segmento */}
                    <View style={styles.detalheProgressBar}>
                      <View style={[styles.detalheProgressFill, { 
                        width: `${detalheMesSelecionado.percentual_no_prazo}%`,
                        backgroundColor: '#2E8B57'
                      }]} />
                      <View style={[styles.detalheProgressFill, { 
                        width: `${detalheMesSelecionado.percentual_apos_prazo_neste_mes}%`,
                        backgroundColor: '#FFD700',
                        marginLeft: 0
                      }]} />
                      <View style={[styles.detalheProgressFill, { 
                        width: `${detalheMesSelecionado.percentual_atrasados_posteriores}%`,
                        backgroundColor: '#FF8C00',
                        marginLeft: 0
                      }]} />
                      <View style={[styles.detalheProgressFill, { 
                        width: `${detalheMesSelecionado.percentual_pendentes}%`,
                        backgroundColor: '#DC143C',
                        marginLeft: 0
                      }]} />
                    </View>
                    
                    {/* Grid 2x2 */}
                    <View style={styles.detalheMesRow}>
                      <View style={styles.detalheMesCol}>
                        <Text style={styles.detalheLabel}>Pagos no Prazo</Text>
                        <Text style={styles.detalheValor}>
                          {detalheMesSelecionado.pagamentos_do_mes_no_prazo}
                        </Text>
                        <Text style={[styles.detalhePercent, { color: '#2E8B57' }]}>
                          {detalheMesSelecionado.percentual_no_prazo.toFixed(2)}%
                        </Text>
                      </View>
                      <View style={styles.detalheMesCol}>
                        <Text style={styles.detalheLabel}>Atrasados (neste mês)</Text>
                        <Text style={styles.detalheValor}>
                          {detalheMesSelecionado.pagamentos_do_mes_apos_prazo_neste_mes}
                        </Text>
                        <Text style={[styles.detalhePercent, { color: '#FFD700' }]}>
                          {detalheMesSelecionado.percentual_apos_prazo_neste_mes.toFixed(2)}%
                        </Text>
                      </View>
                    </View>
                    <View style={styles.detalheMesRow}>
                      <View style={styles.detalheMesCol}>
                        <Text style={styles.detalheLabel}>Pagos em Meses Posteriores</Text>
                        <Text style={styles.detalheValor}>
                          {detalheMesSelecionado.pagamentos_do_mes_atrasados_posteriores}
                        </Text>
                        <Text style={[styles.detalhePercent, { color: '#FF8C00' }]}>
                          {detalheMesSelecionado.percentual_atrasados_posteriores.toFixed(2)}%
                        </Text>
                      </View>
                      <View style={styles.detalheMesCol}>
                        <Text style={styles.detalheLabel}>Ainda Não Pagos</Text>
                        <Text style={styles.detalheValor}>
                          {detalheMesSelecionado.pagamentos_do_mes_pendentes}
                        </Text>
                        <Text style={[styles.detalhePercent, { color: '#DC143C' }]}>
                          {detalheMesSelecionado.percentual_pendentes.toFixed(2)}%
                        </Text>
                      </View>
                    </View>
                    <View style={styles.detalheValorTotal}>
                      <Text style={styles.detalheValorTotalLabel}>Valor recebido neste mês (deste período):</Text>
                      <Text style={styles.detalheValorTotalValue}>
                        {formatCurrency(detalheMesSelecionado.valor_pagamentos_do_mes)}
                      </Text>
                    </View>
                  </View>
                  
                  {/* Pagamentos de Meses Anteriores */}
                  {detalheMesSelecionado.pagamentos_meses_anteriores.length > 0 && (
                    <View style={styles.detalheMesCard}>
                      <Text style={styles.detalheMesCardTitle}>Pagamentos Atrasados Recebidos</Text>
                      <Text style={styles.detalheMesSubtext}>
                        Mensalidades de meses anteriores quitadas neste mês
                      </Text>
                      <View style={styles.detalheValorTotal}>
                        <Text style={styles.detalheValorTotalLabel}>
                          Total: {detalheMesSelecionado.pagamentos_meses_anteriores.reduce((acc, pag) => acc + pag.quantidade, 0)} pagamentos
                        </Text>
                        <Text style={[styles.detalheValorTotalValue, { color: '#FF8C00' }]}>
                          {formatCurrency(detalheMesSelecionado.valor_meses_anteriores)}
                        </Text>
                      </View>
                      {detalheMesSelecionado.pagamentos_meses_anteriores.map((pag, index) => (
                        <View key={index} style={styles.pagamentoAnteriorItem}>
                          <View style={styles.pagamentoAnteriorInfo}>
                            <Ionicons name="calendar-outline" size={16} color="#FF8C00" />
                            <Text style={styles.pagamentoAnteriorMes}>
                              {(() => {
                                const [ano, mes] = pag.mes_origem.split('-');
                                const mesNome = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
                                                'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'][parseInt(mes) - 1];
                                return `${mesNome}/${ano}`;
                              })()}
                            </Text>
                            <Text style={styles.pagamentoAnteriorQtd}>
                              {pag.quantidade} {pag.quantidade === 1 ? 'pagamento' : 'pagamentos'}
                            </Text>
                          </View>
                          <Text style={styles.pagamentoAnteriorValor}>
                            {formatCurrency(pag.valor)}
                          </Text>
                        </View>
                      ))}
                    </View>
                  )}
                </ScrollView>
              </>
            ) : null}
          </View>
        </View>
      </Modal>
      
      <StatusBar style="light" />
    </SafeAreaView>
  );
}
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#121212' },
  scrollView: { flex: 1 },
  scrollContent: { paddingBottom: 40 },
  header: {
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 16
  },
  title: {
    fontSize: 36,
    fontWeight: '800',
    color: '#FFD700',
    marginBottom: 8,
    letterSpacing: 0.5
  },
  subtitle: {
    fontSize: 15,
    color: '#AAAAAA',
    fontWeight: '500'
  },
  loadingText: {
    color: '#AAAAAA',
    fontSize: 16,
    marginTop: 16,
    textAlign: 'center',
    fontWeight: '500'
  },
  kpiSection: {
    paddingHorizontal: 16,
    paddingTop: 8,
    marginBottom: 8
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#FFD700',
    marginBottom: 12,
    paddingLeft: 4
  },
  kpiGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between'
  },
  kpiCard: {
    width: '48%',
    backgroundColor: '#282828',
    padding: 14,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    marginBottom: 12
  },
  kpiHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    marginBottom: 8
  },
  kpiLabel: {
    fontSize: 11,
    color: '#AAAAAA',
    fontWeight: '600',
    flex: 1
  },
  kpiValue: {
    fontSize: 26,
    fontWeight: '900',
    color: '#FFFFFF',
    marginBottom: 2,
    letterSpacing: -0.5
  },
  kpiSubtext: {
    fontSize: 10,
    color: '#888888',
    fontWeight: '500'
  },
  chartCard: {
    backgroundColor: '#282828',
    marginHorizontal: 16,
    marginTop: 20,
    borderRadius: 12,
    padding: 20,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4
  },
  chartHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 16
  },
  chartTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: 4
  },
  chartSubtitle: {
    fontSize: 12,
    color: '#AAAAAA',
    fontWeight: '500'
  },
  chartBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFD700',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 8,
    gap: 4
  },
  badgeContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6
  },
  chartBadgeText: {
    fontSize: 13,
    fontWeight: '800',
    color: '#121212',
    lineHeight: 16
  },
  chartBadgeSubtext: {
    fontSize: 9,
    fontWeight: '600',
    color: '#121212',
    opacity: 0.7,
    lineHeight: 10
  },
  chart: {
    marginLeft: -20,
    marginRight: -8,
    borderRadius: 12
  },
  chartFootnote: {
    fontSize: 10,
    color: '#888888',
    fontStyle: 'italic',
    textAlign: 'center',
    marginTop: 12,
    paddingHorizontal: 4
  },
  tooltipContainer: {
    backgroundColor: '#FFD700',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
    marginBottom: 12,
    alignSelf: 'center',
    elevation: 4,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.4,
    shadowRadius: 4
  },
  tooltipText: {
    fontSize: 13,
    fontWeight: '700',
    color: '#121212',
    textAlign: 'center'
  },
  listCard: {
    backgroundColor: '#282828',
    marginHorizontal: 16,
    marginTop: 20,
    borderRadius: 12,
    padding: 20,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4
  },
  listHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
    gap: 12
  },
  listTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: '#FFFFFF'
  },
  listSubtitle: {
    fontSize: 12,
    color: '#AAAAAA',
    fontWeight: '500',
    marginBottom: 16,
    fontStyle: 'italic'
  },
  listItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: '#3A3A3A'
  },
  listItemLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    flex: 1
  },
  listRank: {
    width: 36,
    height: 36,
    borderRadius: 10,
    backgroundColor: '#1A1A1A',
    justifyContent: 'center',
    alignItems: 'center'
  },
  listRankFirst: {
    backgroundColor: '#FFD700',
    borderWidth: 0
  },
  listRankText: {
    fontSize: 14,
    fontWeight: '900',
    color: '#FFD700'
  },
  listRankTextFirst: {
    color: '#121212'
  },
  listItemName: {
    fontSize: 15,
    fontWeight: '700',
    color: '#FFFFFF',
    marginBottom: 2
  },
  listItemValue: {
    fontSize: 12,
    color: '#AAAAAA',
    fontWeight: '500'
  },
  listItemRight: {
    alignItems: 'flex-end',
    gap: 6
  },
  progressBar: {
    width: 80,
    height: 6,
    backgroundColor: '#1A1A1A',
    borderRadius: 3,
    overflow: 'hidden'
  },
  progressFill: {
    height: '100%',
    borderRadius: 3
  },
  listItemPercent: {
    fontSize: 13,
    fontWeight: '800',
    color: '#AAAAAA'
  },
  compactListItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#3A3A3A'
  },
  compactLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12
  },
  colorDot: {
    width: 10,
    height: 10,
    borderRadius: 5
  },
  compactName: {
    fontSize: 14,
    fontWeight: '700',
    color: '#FFFFFF'
  },
  compactRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6
  },
  compactValue: {
    fontSize: 15,
    fontWeight: '800',
    color: '#FFFFFF'
  },
  compactPercent: {
    fontSize: 13,
    fontWeight: '600',
    color: '#AAAAAA'
  },
  alertCard: {
    backgroundColor: '#282828',
    marginHorizontal: 16,
    marginTop: 20,
    borderRadius: 12,
    padding: 20,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    borderLeftWidth: 4,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4
  },
  alertHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
    gap: 16
  },
  alertHeaderText: {
    flex: 1
  },
  alertTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#AAAAAA',
    marginBottom: 4
  },
  alertValue: {
    fontSize: 32,
    fontWeight: '900'
  },
  alertStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: '#3A3A3A'
  },
  alertStat: {
    alignItems: 'center'
  },
  alertStatLabel: {
    fontSize: 11,
    color: '#AAAAAA',
    fontWeight: '500',
    marginBottom: 4
  },
  alertStatValue: {
    fontSize: 16,
    fontWeight: '800',
    color: '#FFFFFF'
  },
  alertInsight: {
    fontSize: 13,
    color: '#AAAAAA',
    fontWeight: '500',
    fontStyle: 'italic',
    textAlign: 'center'
  },
  summaryCard: {
    backgroundColor: '#282828',
    marginHorizontal: 16,
    marginTop: 20,
    borderRadius: 12,
    padding: 20,
    borderWidth: 2,
    borderColor: '#FFD700',
    elevation: 3,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 6
  },
  summaryTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: '#FFD700',
    marginBottom: 16,
    textAlign: 'center'
  },
  summaryGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between'
  },
  summaryItem: {
    width: '48%',
    padding: 12,
    backgroundColor: '#1A1A1A',
    borderRadius: 12,
    marginBottom: 8
  },
  summaryLabel: {
    fontSize: 11,
    color: '#AAAAAA',
    fontWeight: '500',
    marginBottom: 4
  },
  summaryValue: {
    fontSize: 16,
    fontWeight: '800',
    color: '#FFFFFF'
  },
  detailsContainer: {
    marginTop: 16,
    padding: 16,
    backgroundColor: '#1A1A1A',
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#FFD700'
  },
  closeButton: {
    position: 'absolute',
    top: -8,
    right: -12,
    zIndex: 10,
  },
  pieChartContainer: {
    marginTop: 16,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: '#3A3A3A'
  },
  pieChartTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#FFD700',
    marginBottom: 4,
    textAlign: 'center'
  },
  pieChartSubtitle: {
    fontSize: 12,
    fontWeight: '500',
    color: '#AAAAAA',
    marginBottom: 16,
    textAlign: 'center'
  },
  pieStats: {
    marginTop: 16,
    gap: 12
  },
  pieStat: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 12,
    backgroundColor: '#282828',
    borderRadius: 8
  },
  pieStatDot: {
    width: 12,
    height: 12,
    borderRadius: 6
  },
  pieStatLabel: {
    fontSize: 13,
    color: '#AAAAAA',
    fontWeight: '500',
    marginBottom: 2
  },
  pieStatValue: {
    fontSize: 18,
    fontWeight: '800',
    color: '#FFFFFF'
  },
  pieStatPercent: {
    fontSize: 14,
    fontWeight: '600',
    color: '#AAAAAA'
  },
  pieTotal: {
    marginTop: 8,
    padding: 16,
    backgroundColor: '#FFD700',
    borderRadius: 8,
    alignItems: 'center'
  },
  pieTotalLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#121212',
    marginBottom: 4
  },
  pieTotalValue: {
    fontSize: 24,
    fontWeight: '900',
    color: '#121212'
  },
  noDataContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 40,
    gap: 12
  },
  noDataText: {
    fontSize: 16,
    fontWeight: '700',
    color: '#AAAAAA',
    textAlign: 'center'
  },
  noDataSubtext: {
    fontSize: 13,
    fontWeight: '500',
    color: '#777777',
    textAlign: 'center',
    paddingHorizontal: 20
  },
  debugText: {
    fontSize: 11,
    color: '#FFD700',
    textAlign: 'center',
    marginBottom: 8,
    fontFamily: 'monospace'
  },
  receitaComparisonCard: {
    backgroundColor: '#2A2A2A',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#3A3A3A'
  },
  receitaComparisonRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 12
  },
  receitaComparisonItem: {
    flex: 1,
    backgroundColor: '#1F1F1F',
    borderRadius: 8,
    padding: 12,
    borderWidth: 1,
    borderColor: '#333333'
  },
  receitaComparisonLabel: {
    fontSize: 11,
    fontWeight: '600',
    color: '#AAAAAA',
    marginBottom: 6,
    textTransform: 'uppercase',
    letterSpacing: 0.5
  },
  receitaComparisonValue: {
    fontSize: 18,
    fontWeight: '800',
    color: '#FFD700',
    marginBottom: 4
  },
  receitaComparisonDesc: {
    fontSize: 10,
    fontWeight: '500',
    color: '#888888',
    lineHeight: 14
  },
  receitaDifferenceBox: {
    backgroundColor: '#1A1A1A',
    borderRadius: 8,
    padding: 12,
    borderLeftWidth: 3,
    borderLeftColor: '#FFD700'
  },
  receitaDifferenceText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#DDDDDD',
    textAlign: 'center'
  },
  infoButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#FFD700',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
    marginHorizontal: 8,
  },
  infoButtonText: {
    fontSize: 13,
    fontWeight: '700',
    color: '#121212',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.85)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalDetalheMesContent: {
    backgroundColor: '#1F1F1F',
    borderRadius: 16,
    width: '100%',
    maxWidth: 500,
    maxHeight: '80%',
    borderWidth: 1,
    borderColor: '#3A3A3A',
  },
  modalDetalheMesHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#2A2A2A',
  },
  modalDetalheMesTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  modalDetalheMesBody: {
    padding: 20,
  },
  detalheMesCard: {
    backgroundColor: '#282828',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#3A3A3A',
  },
  detalheMesCardTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: '#FFD700',
    marginBottom: 12,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  detalheMesValorPrincipal: {
    fontSize: 32,
    fontWeight: '900',
    color: '#FFFFFF',
    marginBottom: 8,
  },
  detalheMesSubtext: {
    fontSize: 12,
    fontWeight: '500',
    color: '#AAAAAA',
    marginBottom: 12,
  },
  detalheProgressBar: {
    height: 8,
    backgroundColor: '#1A1A1A',
    borderRadius: 4,
    marginBottom: 16,
    overflow: 'hidden',
  },
  detalheProgressFill: {
    height: '100%',
    borderRadius: 4,
  },
  detalheMesRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 12,
  },
  detalheMesCol: {
    flex: 1,
    backgroundColor: '#1F1F1F',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  detalheLabel: {
    fontSize: 11,
    fontWeight: '600',
    color: '#888888',
    marginBottom: 8,
    textTransform: 'uppercase',
  },
  detalheValor: {
    fontSize: 20,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  detalhePercent: {
    fontSize: 14,
    fontWeight: '700',
    color: '#2E8B57',
  },
  detalheValorTotal: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 12,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#3A3A3A',
  },
  detalheValorTotalLabel: {
    fontSize: 13,
    fontWeight: '600',
    color: '#AAAAAA',
  },
  detalheValorTotalValue: {
    fontSize: 18,
    fontWeight: '800',
    color: '#FFD700',
  },
  pagamentoAnteriorItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#1F1F1F',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
    borderLeftWidth: 3,
    borderLeftColor: '#FF8C00',
  },
  pagamentoAnteriorInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    flex: 1,
  },
  pagamentoAnteriorMes: {
    fontSize: 13,
    fontWeight: '700',
    color: '#FF8C00',
  },
  pagamentoAnteriorQtd: {
    fontSize: 12,
    fontWeight: '500',
    color: '#AAAAAA',
  },
  pagamentoAnteriorValor: {
    fontSize: 15,
    fontWeight: '800',
    color: '#FFFFFF',
  },
});
