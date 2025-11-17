import DateTimePicker from '@react-native-community/datetimepicker';
import axios from 'axios';
import { useRouter, useFocusEffect } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useState, useEffect, useCallback } from 'react';
import {
    Alert,
    SafeAreaView,
    ScrollView,
    StyleSheet,
    Text,
    TextInput,
    TouchableOpacity,
    View,
    useWindowDimensions,
    ActivityIndicator,
    Platform,
    Modal
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { API_URL } from '../../config/api';
interface Modalidade {
  id_modalidade: number;
  nome: string;
}
interface Plano {
  id_plano: number;
  nome: string;
  preco_mensal: number;
  descricao?: string;
}
export default function AddAlunoScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { width } = useWindowDimensions();
  const isWeb = width > 768;
  const [nomeCompleto, setNomeCompleto] = useState('');
  const [email, setEmail] = useState('');
  const [telefone, setTelefone] = useState('');
  const [cpf, setCpf] = useState('');
  const [sexo, setSexo] = useState('');
  const [dataNascimento, setDataNascimento] = useState(new Date());
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [dateInputText, setDateInputText] = useState('');
  const [planos, setPlanos] = useState<Plano[]>([]);
  const [modalidades, setModalidades] = useState<Modalidade[]>([]);
  const [planoSelecionado, setPlanoSelecionado] = useState<number | null>(null);
  const [modalidadesSelecionadas, setModalidadesSelecionadas] = useState<number[]>([]);
  const [loading, setLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(true);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const [fieldErrors, setFieldErrors] = useState<{
    nomeCompleto?: string;
    email?: string;
    telefone?: string;
    cpf?: string;
    sexo?: string;
    dataNascimento?: string;
    plano?: string;
    modalidades?: string;
  }>({});
  const getMaxModalidades = (planoNome: string | undefined): number => {
    if (!planoNome) return 0;
    const nome = planoNome.toLowerCase();
    if (nome.includes('starter')) return 1;
    if (nome.includes('light')) return 2;
    if (nome.includes('premium')) return 4;
    if (nome.includes('fighter')) return 999;
    return 0;
  };
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [planosRes, modalidadesRes] = await Promise.all([
          axios.get(`${API_URL}/planos/`),
          axios.get(`${API_URL}/planos/modalidades/`)
        ]);
        setPlanos(planosRes.data);
        setModalidades(modalidadesRes.data);
      } catch (error) {
        console.error('Erro ao carregar dados:', error);
        Alert.alert('Erro', 'Não foi possível carregar os planos e modalidades.');
      } finally {
        setLoadingData(false);
      }
    };
    fetchData();
  }, []);
  const resetForm = useCallback(() => {
    setNomeCompleto('');
    setEmail('');
    setTelefone('');
    setCpf('');
    setSexo('');
    setDataNascimento(new Date());
    setDateInputText('');
    setPlanoSelecionado(null);
    setModalidadesSelecionadas([]);
    setLoading(false);
    setErrorMessage('');
    setSuccessMessage('');
    setFieldErrors({});
  }, []);
  useFocusEffect(
    useCallback(() => {
      resetForm();
    }, [resetForm])
  );
  useEffect(() => {
    if (modalidades.length > 0) {
    }
  }, [modalidades]);
  useEffect(() => {
    if (planoSelecionado) {
    }
  }, [planoSelecionado]);
  const formatCPF = (text: string) => {
    const numbers = text.replace(/\D/g, '');
    if (numbers.length <= 3) return numbers;
    if (numbers.length <= 6) return `${numbers.slice(0, 3)}.${numbers.slice(3)}`;
    if (numbers.length <= 9) return `${numbers.slice(0, 3)}.${numbers.slice(3, 6)}.${numbers.slice(6)}`;
    return `${numbers.slice(0, 3)}.${numbers.slice(3, 6)}.${numbers.slice(6, 9)}-${numbers.slice(9, 11)}`;
  };
  const formatPhone = (text: string) => {
    const numbers = text.replace(/\D/g, '');
    if (numbers.length <= 2) return `(${numbers}`;
    if (numbers.length <= 7) return `(${numbers.slice(0, 2)}) ${numbers.slice(2)}`;
    return `(${numbers.slice(0, 2)}) ${numbers.slice(2, 7)}-${numbers.slice(7, 11)}`;
  };
  const onChangeDate = (event: any, selectedDate?: Date) => {
    const currentDate = selectedDate || dataNascimento;
    if (Platform.OS === 'android') {
      setShowDatePicker(false);
    }
    if (event.type === 'set' && selectedDate) {
      setDataNascimento(selectedDate);
      setShowDatePicker(false);
    } else if (event.type === 'dismissed') {
      setShowDatePicker(false);
    }
  };
  const handlePlanoChange = (planoId: number | null) => {
    setPlanoSelecionado(planoId);
    if (planoId) {
      const planoSelecionadoObj = planos.find(p => p.id_plano === planoId);
      if (planoSelecionadoObj && planoSelecionadoObj.nome.toLowerCase().includes('fighter')) {
        const todasModalidadesIds = modalidades.map(m => m.id_modalidade);
        setModalidadesSelecionadas(todasModalidadesIds);
      } else {
        setModalidadesSelecionadas([]);
      }
    } else {
      setModalidadesSelecionadas([]);
    }
    if (fieldErrors.plano) {
      setFieldErrors(prev => ({ ...prev, plano: undefined }));
    }
  };
  useEffect(() => {
    if (showDatePicker) {
      const day = String(dataNascimento.getDate()).padStart(2, '0');
      const month = String(dataNascimento.getMonth() + 1).padStart(2, '0');
      const year = dataNascimento.getFullYear();
      setDateInputText(`${day}/${month}/${year}`);
    }
  }, [showDatePicker]);
  const toggleModalidade = (modalidadeId: number) => {
    const planoAtual = planos.find(p => p.id_plano === planoSelecionado);
    const maxModalidades = getMaxModalidades(planoAtual?.nome);
    const modalidade = modalidades.find(m => m.id_modalidade === modalidadeId);
    if (!modalidade) return;
    if (maxModalidades === 999) {
      Alert.alert(
        'Plano Fighter',
        'O plano Fighter inclui automaticamente todas as modalidades e n�o pode ser alterado.'
      );
      return;
    }
    if (modalidadesSelecionadas.includes(modalidadeId)) {
      setModalidadesSelecionadas(modalidadesSelecionadas.filter(id => id !== modalidadeId));
    } else {
      if (modalidadesSelecionadas.length >= maxModalidades && maxModalidades < 999) {
        Alert.alert('Limite atingido', `Este plano permite no m�ximo ${maxModalidades} modalidade(s).`);
        return;
      }
      setModalidadesSelecionadas([...modalidadesSelecionadas, modalidadeId]);
      if (fieldErrors.modalidades) {
        setFieldErrors(prev => ({ ...prev, modalidades: undefined }));
      }
    }
  };
  const isModalidadeDisabled = (modalidade: Modalidade): boolean => {
    if (!planoSelecionado) return true;
    const planoAtual = planos.find(p => p.id_plano === planoSelecionado);
    const maxModalidades = getMaxModalidades(planoAtual?.nome);
    if (maxModalidades === 999) return true;
    if (modalidadesSelecionadas.includes(modalidade.id_modalidade)) {
      return false;
    }
    if (modalidadesSelecionadas.length >= maxModalidades && maxModalidades < 999) {
      return true;
    }
    return false;
  };
  const validate = () => {

    const errors: typeof fieldErrors = {};
    let isValid = true;
    if (!nomeCompleto.trim()) {
      errors.nomeCompleto = 'Nome completo � obrigat�rio';
      isValid = false;
    } else if (nomeCompleto.split(' ').filter(n => n.length > 0).length < 2) {
      errors.nomeCompleto = 'Informe nome e sobrenome';
      isValid = false;
    }
    if (!email.trim()) {
      errors.email = 'Email � obrigat�rio';
      isValid = false;
    } else if (!email.includes('@') || !email.includes('.')) {
      errors.email = 'Email inv�lido (ex: nome@email.com)';
      isValid = false;
    }
    const telefoneNumbers = telefone.replace(/\D/g, '');
    if (!telefone.trim()) {
      errors.telefone = 'Telefone � obrigat�rio';
      isValid = false;
    } else if (telefoneNumbers.length < 10) {
      errors.telefone = 'Telefone inv�lido (m�nimo 10 d�gitos)';
      isValid = false;
    }
    const cpfNumbers = cpf.replace(/\D/g, '');
    if (!cpf.trim()) {
      errors.cpf = 'CPF � obrigat�rio';
      isValid = false;
    } else if (cpfNumbers.length !== 11) {
      errors.cpf = 'CPF deve ter 11 d�gitos';
      isValid = false;
    }
    if (!sexo) {
      errors.sexo = 'Selecione o sexo';
      isValid = false;
    }
    const hoje = new Date();
    const idade = hoje.getFullYear() - dataNascimento.getFullYear();
    const mesAtual = hoje.getMonth();
    const mesNasc = dataNascimento.getMonth();
    const diaAtual = hoje.getDate();
    const diaNasc = dataNascimento.getDate();
    let idadeReal = idade;
    if (mesAtual < mesNasc || (mesAtual === mesNasc && diaAtual < diaNasc)) {
      idadeReal--;
    }
    if (idadeReal < 16) {
      errors.dataNascimento = 'Idade m�nima: 16 anos';
      isValid = false;
    }
    if (!planoSelecionado) {
      errors.plano = 'Selecione um plano';
      isValid = false;
    }
    const planoAtual = planos.find(p => p.id_plano === planoSelecionado);
    const maxModalidades = getMaxModalidades(planoAtual?.nome);
    if (maxModalidades < 999 && modalidadesSelecionadas.length === 0) {
      errors.modalidades = 'Selecione pelo menos uma modalidade';
      isValid = false;
    }
    setFieldErrors(errors);
    if (!isValid) {

    } else {

    }
    return isValid;
  };
  const handleSalvarAluno = async () => {


    setErrorMessage('');
    setSuccessMessage('');
    if (!validate()) {

      return;
    }

    setLoading(true);
    try {
      const novoAluno = {
        nome_completo: nomeCompleto.trim(),
        email: email.trim().toLowerCase(),
        telefone: telefone.replace(/\D/g, ''),
        cpf: cpf,
        sexo: sexo,
        data_nascimento: dataNascimento.toISOString().split('T')[0],
      };
      const alunoResponse = await axios.post(`${API_URL}/alunos/`, novoAluno);

      const matricula = alunoResponse.data.matricula;

      const dataInicio = new Date();
      const novaInscricao = {
        id_aluno: matricula,
        id_plano: planoSelecionado,
        data_inicio: dataInicio.toISOString().split('T')[0],
      };

      const inscricaoResponse = await axios.post(`${API_URL}/inscricoes/`, novaInscricao);
      const idInscricao = inscricaoResponse.data.id_inscricao;


      for (const modalidadeId of modalidadesSelecionadas) {
        try {
          await axios.post(`${API_URL}/inscricoes/${idInscricao}/modalidades/${modalidadeId}`);

        } catch (error) {
          console.error(`❌ Erro ao adicionar modalidade ${modalidadeId}:`, error);
        }
      }

      const planoAtual = planos.find(p => p.id_plano === planoSelecionado);
      const valorPlano = planoAtual?.preco_mensal || 0;
      const dataVencimento = new Date();
      dataVencimento.setMonth(dataVencimento.getMonth() + 1);
      dataVencimento.setDate(10);
      const novoPagamento = {
        id_inscricao: idInscricao,
        data_vencimento: dataVencimento.toISOString().split('T')[0],
        valor_total_devido: valorPlano,
        itens: [
          {
            id_tipo_transacao: 1,
            descricao: `Mensalidade ${planoAtual?.nome} - ${new Date().toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' })}`,
            valor: valorPlano
          }
        ]
      };

      await axios.post(`${API_URL}/pagamentos/`, novoPagamento);

      router.push({
        pathname: '/(tabs)/home',
        params: {
          cadastroSucesso: 'true',
          matricula: matricula,
          planoNome: planoAtual?.nome || '',
          dataVencimento: dataVencimento.toLocaleDateString('pt-BR')
        }
      });
    } catch (error: any) {
      console.error("Erro ao salvar:", error);
      console.error("Detalhes do erro:", error.response?.data);
      console.error("Status:", error.response?.status);
      const errors: typeof fieldErrors = {};
      let errorMsg = 'Não foi possível completar o cadastro. Tente novamente.';
      if (error.response?.data?.detail) {
        const detail = error.response.data.detail;
        if (typeof detail === 'string') {
          if (detail.toLowerCase().includes('cpf') && detail.toLowerCase().includes('já existe')) {
            errors.cpf = 'CPF já cadastrado no sistema';
            errorMsg = 'CPF já cadastrado. Verifique os dados ou consulte um administrador.';
          } else if (detail.toLowerCase().includes('email') && detail.toLowerCase().includes('já existe')) {
            errors.email = 'Email já cadastrado no sistema';
            errorMsg = 'Email já cadastrado. Use outro email.';
          } else {
            errorMsg = detail;
          }
        } else if (Array.isArray(detail)) {
          detail.forEach((err: any) => {
            const field = err.loc[err.loc.length - 1];
            const message = err.msg;
            if (field === 'nome_completo') errors.nomeCompleto = message;
            else if (field === 'email') errors.email = message;
            else if (field === 'telefone') errors.telefone = message;
            else if (field === 'cpf') errors.cpf = message;
            else if (field === 'sexo') errors.sexo = message;
            else if (field === 'data_nascimento') errors.dataNascimento = message;
          });
          errorMsg = 'Corrija os erros nos campos destacados.';
        }
      }
      setFieldErrors(errors);
      setErrorMessage(`❌ ${errorMsg}`);
    } finally {
      setLoading(false);
    }
  };
  if (loadingData) {
    return (
      <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#FFD700" />
          <Text style={styles.loadingText}>Carregando...</Text>
        </View>
        <StatusBar style="light" />
      </SafeAreaView>
    );
  }
  return (
    <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        <View style={[styles.contentWrapper, isWeb && styles.contentWrapperWeb]}>
          <Text style={styles.title}>Cadastrar Novo Aluno</Text>
          {}
          {errorMessage && (
            <View style={styles.errorBox}>
              <Text style={styles.errorText}>{errorMessage}</Text>
              <TouchableOpacity
                style={styles.closeErrorButton}
                onPress={() => setErrorMessage('')}
              >
                <Ionicons name="close-circle" size={24} color="#FF6B6B" />
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, { marginTop: 12, backgroundColor: '#FF6B6B' }]}
                onPress={() => {
                  setErrorMessage('');
                  handleSalvarAluno();
                }}
              >
                <Text style={styles.buttonText}>Tentar Novamente</Text>
              </TouchableOpacity>
            </View>
          )}
          <View style={styles.form}>
          {}
          <Text style={styles.sectionTitle}>Dados Pessoais</Text>
          <Text style={styles.label}>Nome Completo *</Text>
          <TextInput
            placeholder="Ex: João Silva Santos"
            value={nomeCompleto}
            onChangeText={(text) => {
              setNomeCompleto(text);
              if (fieldErrors.nomeCompleto) {
                setFieldErrors(prev => ({ ...prev, nomeCompleto: undefined }));
              }
            }}
            placeholderTextColor="#777"
            style={[styles.input, fieldErrors.nomeCompleto && styles.inputError]}
          />
          {fieldErrors.nomeCompleto && (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
              <Text style={styles.fieldErrorText}>{fieldErrors.nomeCompleto}</Text>
            </View>
          )}
          <Text style={styles.label}>Email *</Text>
          <TextInput
            placeholder="email@exemplo.com"
            value={email}
            onChangeText={(text) => {
              setEmail(text);
              if (fieldErrors.email) {
                setFieldErrors(prev => ({ ...prev, email: undefined }));
              }
            }}
            placeholderTextColor="#777"
            style={[styles.input, fieldErrors.email && styles.inputError]}
            keyboardType="email-address"
            autoCapitalize="none"
          />
          {fieldErrors.email && (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
              <Text style={styles.fieldErrorText}>{fieldErrors.email}</Text>
            </View>
          )}
          <Text style={styles.label}>Telefone *</Text>
          <TextInput
            placeholder="(00) 00000-0000"
            value={telefone}
            onChangeText={(text) => {
              setTelefone(formatPhone(text));
              if (fieldErrors.telefone) {
                setFieldErrors(prev => ({ ...prev, telefone: undefined }));
              }
            }}
            placeholderTextColor="#777"
            style={[styles.input, fieldErrors.telefone && styles.inputError]}
            keyboardType="phone-pad"
            maxLength={15}
          />
          {fieldErrors.telefone && (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
              <Text style={styles.fieldErrorText}>{fieldErrors.telefone}</Text>
            </View>
          )}
          <Text style={styles.label}>CPF *</Text>
          <TextInput
            placeholder="000.000.000-00"
            value={cpf}
            onChangeText={(text) => {
              setCpf(formatCPF(text));
              if (fieldErrors.cpf) {
                setFieldErrors(prev => ({ ...prev, cpf: undefined }));
              }
            }}
            placeholderTextColor="#777"
            style={[styles.input, fieldErrors.cpf && styles.inputError]}
            keyboardType="numeric"
            maxLength={14}
          />
          {fieldErrors.cpf && (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
              <Text style={styles.fieldErrorText}>{fieldErrors.cpf}</Text>
            </View>
          )}
          <Text style={styles.label}>Sexo *</Text>
          <View style={styles.sexoContainer}>
            <TouchableOpacity
              style={[styles.sexoButton, sexo === 'Masculino' && styles.sexoButtonSelected]}
              onPress={() => {
                setSexo('Masculino');
                if (fieldErrors.sexo) {
                  setFieldErrors(prev => ({ ...prev, sexo: undefined }));
                }
              }}
            >
              <Ionicons name="male" size={20} color={sexo === 'Masculino' ? '#000' : '#FFD700'} />
              <Text style={[styles.sexoButtonText, sexo === 'Masculino' && styles.sexoButtonTextSelected]}>
                Masculino
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.sexoButton, sexo === 'Feminino' && styles.sexoButtonSelected]}
              onPress={() => {
                setSexo('Feminino');
                if (fieldErrors.sexo) {
                  setFieldErrors(prev => ({ ...prev, sexo: undefined }));
                }
              }}
            >
              <Ionicons name="female" size={20} color={sexo === 'Feminino' ? '#000' : '#FFD700'} />
              <Text style={[styles.sexoButtonText, sexo === 'Feminino' && styles.sexoButtonTextSelected]}>
                Feminino
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.sexoButton, sexo === 'Outro' && styles.sexoButtonSelected]}
              onPress={() => {
                setSexo('Outro');
                if (fieldErrors.sexo) {
                  setFieldErrors(prev => ({ ...prev, sexo: undefined }));
                }
              }}
            >
              <Ionicons name="person" size={20} color={sexo === 'Outro' ? '#000' : '#FFD700'} />
              <Text style={[styles.sexoButtonText, sexo === 'Outro' && styles.sexoButtonTextSelected]}>
                Outro
              </Text>
            </TouchableOpacity>
          </View>
          {fieldErrors.sexo && (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
              <Text style={styles.fieldErrorText}>{fieldErrors.sexo}</Text>
            </View>
          )}
          <Text style={styles.label}>Data de Nascimento *</Text>
          <TouchableOpacity
            onPress={() => setShowDatePicker(true)}
            style={[styles.dateButton, fieldErrors.dataNascimento && styles.inputError]}
            activeOpacity={0.7}
          >
            <Ionicons name="calendar-outline" size={20} color="#FFD700" />
            <Text style={styles.dateText}>{dataNascimento.toLocaleDateString('pt-BR')}</Text>
          </TouchableOpacity>
          {fieldErrors.dataNascimento && (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
              <Text style={styles.fieldErrorText}>{fieldErrors.dataNascimento}</Text>
            </View>
          )}
          {Platform.OS === 'web' ? (
            <Modal
              visible={showDatePicker}
              transparent={true}
              animationType="fade"
              onRequestClose={() => setShowDatePicker(false)}
            >
              <View style={styles.modalOverlay}>
                <View style={styles.modalContent}>
                  <Text style={styles.modalTitle}>Selecione a Data de Nascimento</Text>
                  <TextInput
                    style={styles.dateInput}
                    value={dateInputText}
                    onChangeText={(text) => {
                      setDateInputText(text);
                      const dateStr = text.replace(/[^\d/]/g, '');
                      if (dateStr.match(/^\d{2}\/\d{2}\/\d{4}$/)) {
                        try {
                          const [day, month, year] = dateStr.split('/').map(Number);
                          const newDate = new Date(year, month - 1, day);
                          if (newDate.getFullYear() === year &&
                              newDate.getMonth() === month - 1 &&
                              newDate.getDate() === day) {
                            setDataNascimento(newDate);
                          }
                        } catch (e) {
                        }
                      }
                    }}
                    placeholder="DD/MM/AAAA (ex: 15/01/2000)"
                    placeholderTextColor="#777"
                    keyboardType="numeric"
                    autoFocus={true}
                  />
                  <Text style={styles.dateHelp}>
                    Digite no formato: Dia/Mês/Ano
                  </Text>
                  <Text style={styles.datePreview}>
                    {dataNascimento.toLocaleDateString('pt-BR', {
                      weekday: 'long',
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric'
                    })}
                  </Text>
                  <View style={styles.modalButtonsRow}>
                    <TouchableOpacity
                      style={[styles.modalButton, { backgroundColor: '#3A3A3A', flex: 1 }]}
                      onPress={() => setShowDatePicker(false)}
                    >
                      <Text style={[styles.modalButtonText, { color: '#FFF' }]}>Cancelar</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                      style={[styles.modalButton, { flex: 1 }]}
                      onPress={() => setShowDatePicker(false)}
                    >
                      <Text style={styles.modalButtonText}>Confirmar</Text>
                    </TouchableOpacity>
                  </View>
                </View>
              </View>
            </Modal>
          ) : (
            showDatePicker && (
              <DateTimePicker
                value={dataNascimento}
                mode="date"
                display={Platform.OS === 'ios' ? 'spinner' : 'default'}
                onChange={onChangeDate}
                maximumDate={new Date()}
                minimumDate={new Date(1920, 0, 1)}
              />
            )
          )}
          {}
          <Text style={styles.sectionTitle}>Plano e Modalidades</Text>
          <Text style={styles.label}>Plano *</Text>
          <View style={styles.planosContainer}>
            {planos.map((plano) => (
              <TouchableOpacity
                key={plano.id_plano}
                style={[
                  styles.planoCard,
                  planoSelecionado === plano.id_plano && styles.planoCardSelected
                ]}
                onPress={() => handlePlanoChange(plano.id_plano)}
              >
                <View style={styles.planoHeader}>
                  <Text style={[
                    styles.planoNome,
                    planoSelecionado === plano.id_plano && styles.planoNomeSelected
                  ]}>
                    {plano.nome}
                  </Text>
                  {planoSelecionado === plano.id_plano && (
                    <Ionicons name="checkmark-circle" size={24} color="#FFD700" />
                  )}
                </View>
                <Text style={styles.planoPreco}>
                  R$ {parseFloat(plano.preco_mensal.toString()).toFixed(2)}/mês
                </Text>
                <Text style={styles.planoDescricao}>
                  {getMaxModalidades(plano.nome) === 999
                    ? 'Todas as modalidades'
                    : `Escolha até ${getMaxModalidades(plano.nome)} modalidade(s)`}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
          {}
          {planoSelecionado && (() => {
            const planoAtual = planos.find(p => p.id_plano === planoSelecionado);
            const planoNome = planoAtual?.nome.toLowerCase() || '';
            return (
              <View style={{ marginTop: 20 }}>
                <Text style={styles.label}>
                  Modalidades *
                  {modalidadesSelecionadas.length > 0 &&
                    ` (${modalidadesSelecionadas.length} selecionada(s))`
                  }
                </Text>
                {}
                <View>
                  <View style={styles.modalidadesContainer}>
                    {modalidades.map((modalidade) => {
                      const isSelected = modalidadesSelecionadas.includes(modalidade.id_modalidade);
                      const isDisabled = isModalidadeDisabled(modalidade);
                      return (
                        <TouchableOpacity
                          key={modalidade.id_modalidade}
                          style={[
                            styles.modalidadeCard,
                            isSelected && styles.modalidadeCardSelected,
                            isDisabled && styles.modalidadeCardDisabled
                          ]}
                          onPress={() => {
                            toggleModalidade(modalidade.id_modalidade);
                          }}
                          disabled={isDisabled}
                        >
                          <View style={styles.checkboxContainer}>
                            <View style={[
                              styles.checkbox,
                              isSelected && styles.checkboxSelected
                            ]}>
                              {isSelected && <Ionicons name="checkmark" size={16} color="#000" />}
                            </View>
                            <Text style={[
                              styles.modalidadeNome,
                              isSelected && styles.modalidadeNomeSelected,
                              isDisabled && styles.modalidadeNomeDisabled
                            ]}>
                              {modalidade.nome}
                            </Text>
                          </View>
                        </TouchableOpacity>
                      );
                    })}
                </View>
              </View>
              {fieldErrors.modalidades && (
                <View style={styles.errorContainer}>
                  <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
                  <Text style={styles.fieldErrorText}>{fieldErrors.modalidades}</Text>
                </View>
              )}
            </View>
          );
          })()}
          {fieldErrors.plano && (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
              <Text style={styles.fieldErrorText}>{fieldErrors.plano}</Text>
            </View>
          )}
          <TouchableOpacity
            onPress={() => {

              handleSalvarAluno();
            }}
            style={[styles.button, loading && styles.buttonDisabled]}
            disabled={loading}
          >
            <Text style={styles.buttonText}>
              {loading ? 'Salvando...' : 'Cadastrar Aluno'}
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => router.back()}
            style={styles.cancelButton}
            disabled={loading}
          >
            <Text style={styles.cancelButtonText}>
              {loading ? 'Aguarde...' : 'Cancelar'}
            </Text>
          </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
      <StatusBar style="light" />
    </SafeAreaView>
  );
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212'
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: 40,
  },
  contentWrapper: {
    width: '100%',
  },
  contentWrapperWeb: {
    maxWidth: 800,
    alignSelf: 'center',
    paddingHorizontal: 20,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    color: '#FFFFFF',
    fontSize: 16,
    marginTop: 12,
  },
  title: {
    fontSize: 32,
    fontWeight: '800',
    color: '#FFD700',
    textAlign: 'center',
    marginVertical: 28,
    letterSpacing: 0.5,
  },
  form: {
    paddingHorizontal: 20
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#FFD700',
    marginTop: 24,
    marginBottom: 16,
    letterSpacing: 0.5,
  },
  label: {
    color: '#CCCCCC',
    fontSize: 15,
    marginBottom: 10,
    marginTop: 8,
    fontWeight: '600',
    letterSpacing: 0.3,
  },
  input: {
    backgroundColor: '#282828',
    color: '#FFFFFF',
    paddingHorizontal: 18,
    paddingVertical: 14,
    borderRadius: 12,
    fontSize: 16,
    marginBottom: 18,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    fontWeight: '500',
  },
  inputError: {
    borderColor: '#FF6B6B',
    borderWidth: 2,
    marginBottom: 8,
  },
  errorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    marginBottom: 16,
    marginTop: 4,
    paddingLeft: 4,
  },
  fieldErrorText: {
    color: '#FF6B6B',
    fontSize: 13,
    fontWeight: '600',
  },
  sexoContainer: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 18,
  },
  sexoButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#282828',
    paddingVertical: 16,
    paddingHorizontal: 12,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    gap: 8,
  },
  sexoButtonSelected: {
    backgroundColor: '#FFD700',
    borderColor: '#FFD700',
  },
  sexoButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  sexoButtonTextSelected: {
    color: '#000000',
  },
  dateButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#282828',
    paddingHorizontal: 18,
    paddingVertical: 14,
    borderRadius: 12,
    marginBottom: 18,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    gap: 12,
  },
  dateText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '500',
  },
  planosContainer: {
    gap: 12,
    marginBottom: 20,
  },
  planoCard: {
    backgroundColor: '#282828',
    padding: 16,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#3A3A3A',
  },
  planoCardSelected: {
    borderColor: '#FFD700',
    backgroundColor: '#2A2A10',
  },
  planoHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  planoNome: {
    fontSize: 18,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  planoNomeSelected: {
    color: '#FFD700',
  },
  planoPreco: {
    fontSize: 20,
    fontWeight: '700',
    color: '#FFD700',
    marginBottom: 4,
  },
  planoDescricao: {
    fontSize: 14,
    color: '#AAAAAA',
  },
  categoriaTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFD700',
    marginTop: 16,
    marginBottom: 12,
  },
  modalidadesContainer: {
    gap: 10,
    marginBottom: 12,
  },
  modalidadeCard: {
    backgroundColor: '#282828',
    padding: 14,
    borderRadius: 10,
    borderWidth: 2,
    borderColor: '#3A3A3A',
  },
  modalidadeCardSelected: {
    borderColor: '#FFD700',
    backgroundColor: '#2A2A10',
  },
  modalidadeCardDisabled: {
    opacity: 0.4,
  },
  checkboxContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 6,
    borderWidth: 2,
    borderColor: '#555',
    backgroundColor: '#1E1E1E',
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkboxSelected: {
    backgroundColor: '#FFD700',
    borderColor: '#FFD700',
  },
  modalidadeNome: {
    fontSize: 16,
    color: '#FFFFFF',
    fontWeight: '500',
  },
  modalidadeNomeSelected: {
    color: '#FFD700',
    fontWeight: '600',
  },
  modalidadeNomeDisabled: {
    color: '#666',
  },
  button: {
    backgroundColor: '#FFD700',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 24,
    elevation: 4,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  buttonDisabled: {
    backgroundColor: '#998800',
    opacity: 0.6,
  },
  buttonText: {
    color: '#000000',
    fontWeight: '700',
    fontSize: 18,
    letterSpacing: 1,
  },
  cancelButton: {
    backgroundColor: '#3A3A3A',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 12,
    borderWidth: 1,
    borderColor: '#555',
  },
  cancelButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: '#1E1E1E',
    borderRadius: 16,
    padding: 24,
    width: '90%',
    maxWidth: 400,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#FFD700',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#FFD700',
    marginBottom: 20,
    textAlign: 'center',
  },
  modalButton: {
    backgroundColor: '#FFD700',
    paddingVertical: 12,
    paddingHorizontal: 32,
    borderRadius: 8,
    marginTop: 20,
    width: '100%',
    alignItems: 'center',
  },
  modalButtonText: {
    color: '#000',
    fontSize: 16,
    fontWeight: '700',
  },
  dateInput: {
    backgroundColor: '#282828',
    color: '#FFFFFF',
    borderWidth: 2,
    borderColor: '#FFD700',
    borderRadius: 8,
    padding: 12,
    fontSize: 18,
    textAlign: 'center',
    width: '100%',
    marginBottom: 16,
    fontWeight: '600',
  },
  datePickerButtons: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 16,
    width: '100%',
  },
  dateYearButton: {
    flex: 1,
    backgroundColor: '#3A3A3A',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#555',
  },
  dateButtonText: {
    color: '#FFD700',
    fontSize: 14,
    fontWeight: '600',
  },
  datePreview: {
    color: '#FFFFFF',
    fontSize: 14,
    marginBottom: 16,
    textAlign: 'center',
    fontStyle: 'italic',
  },
  dateMonthButton: {
    flex: 1,
    backgroundColor: '#2A2A2A',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#FFD700',
  },
  modalButtonsRow: {
    flexDirection: 'row',
    gap: 12,
    width: '100%',
  },
  dateHelp: {
    color: '#AAA',
    fontSize: 12,
    marginBottom: 12,
    textAlign: 'center',
  },
  successBox: {
    backgroundColor: '#2D4A2B',
    borderWidth: 2,
    borderColor: '#4CAF50',
    borderRadius: 12,
    padding: 20,
    marginVertical: 16,
    alignItems: 'center',
  },
  successText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 8,
  },
  redirectText: {
    color: '#4CAF50',
    fontSize: 14,
    fontStyle: 'italic',
    marginTop: 8,
  },
  errorBox: {
    backgroundColor: '#4A2D2D',
    borderWidth: 2,
    borderColor: '#FF6B6B',
    borderRadius: 12,
    padding: 20,
    marginVertical: 16,
    position: 'relative',
  },
  errorText: {
    color: '#FFFFFF',
    fontSize: 14,
    lineHeight: 22,
    paddingRight: 30,
  },
  closeErrorButton: {
    position: 'absolute',
    top: 12,
    right: 12,
  },
});
const pickerSelectStyles = StyleSheet.create({
  inputIOS: {
    fontSize: 16,
    paddingVertical: 14,
    paddingHorizontal: 18,
    backgroundColor: '#282828',
    borderRadius: 12,
    color: 'white',
    marginBottom: 18,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    fontWeight: '500',
  },
  inputAndroid: {
    fontSize: 16,
    paddingHorizontal: 18,
    paddingVertical: 14,
    backgroundColor: '#282828',
    borderRadius: 12,
    color: 'white',
    marginBottom: 18,
    borderWidth: 2,
    borderColor: '#3A3A3A',
    fontWeight: '500',
  },
});
