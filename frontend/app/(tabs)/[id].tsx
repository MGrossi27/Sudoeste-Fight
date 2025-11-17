import { Ionicons } from '@expo/vector-icons';
import axios from 'axios';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';
import {
    ActivityIndicator,
    Alert,
    SafeAreaView,
    ScrollView,
    StyleSheet,
    Text,
    TouchableOpacity,
    View,
    useWindowDimensions,
    TextInput,
    Modal,
    Platform
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import DateTimePicker from '@react-native-community/datetimepicker';
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
interface Aluno {
  matricula: string;
  nome_completo: string;
  email: string;
  telefone: string;
  cpf: string;
  data_nascimento: string;
  data_cadastro: string;
  sexo: string;
}
interface Inscricao {
  id_inscricao: number;
  plano_nome: string;
  plano_preco: number;
  data_inicio: string;
  data_fim: string | null;
  status: string;
  modalidades?: Array<{
    id_modalidade: number;
    nome: string;
  }>;
}
interface Pagamento {
  id_pagamento: number;
  data_vencimento: string;
  data_pagamento: string | null;
  valor_total_devido: number;
  valor_total_pago: number | null;
  status: string;
}
export default function AlunoDetailScreen() {
  const params = useLocalSearchParams();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const isWeb = width > 768;
  const [aluno, setAluno] = useState<Aluno | null>(null);
  const [inscricoes, setInscricoes] = useState<Inscricao[]>([]);
  const [pagamentos, setPagamentos] = useState<Pagamento[]>([]);
  const [mostrarTodosPagamentos, setMostrarTodosPagamentos] = useState(false);
  const [loading, setLoading] = useState(true);
  const [modalPagamentoVisible, setModalPagamentoVisible] = useState(false);
  const [pagamentoSelecionado, setPagamentoSelecionado] = useState<Pagamento | null>(null);
  const [processandoPagamento, setProcessandoPagamento] = useState(false);
  const [modalCancelamentoVisible, setModalCancelamentoVisible] = useState(false);
  const [dadosCancelamento, setDadosCancelamento] = useState<{
    inscricaoId: number;
    boletosPendentes: number;
    boletosAtrasados: number;
  } | null>(null);
  const [processandoCancelamento, setProcessandoCancelamento] = useState(false);
  const [modalResultadoVisible, setModalResultadoVisible] = useState(false);
  const [resultadoTipo, setResultadoTipo] = useState<'sucesso' | 'erro'>('sucesso');
  const [resultadoMensagem, setResultadoMensagem] = useState('');
  const [modoEdicao, setModoEdicao] = useState(false);
  const [editNomeCompleto, setEditNomeCompleto] = useState('');
  const [editEmail, setEditEmail] = useState('');
  const [editTelefone, setEditTelefone] = useState('');
  const [editCpf, setEditCpf] = useState('');
  const [editSexo, setEditSexo] = useState('');
  const [editDataNascimento, setEditDataNascimento] = useState(new Date());
  const [showEditDatePicker, setShowEditDatePicker] = useState(false);
  const [editDateInputText, setEditDateInputText] = useState('');
  const [planos, setPlanos] = useState<Plano[]>([]);
  const [modalidades, setModalidades] = useState<Modalidade[]>([]);
  const [editPlanoSelecionado, setEditPlanoSelecionado] = useState<number | null>(null);
  const [editModalidadesSelecionadas, setEditModalidadesSelecionadas] = useState<number[]>([]);
  const [setInscricaoAtivaId] = useState<number | null>(null);
  const [loadingSave, setLoadingSave] = useState(false);
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
  const matricula = params.id as string;
  useEffect(() => {
    loadAlunoData();
  }, [matricula]);
  useEffect(() => {
    if (modoEdicao) {





    }
  }, [modoEdicao, editPlanoSelecionado, editModalidadesSelecionadas]);
  const loadAlunoData = async () => {
    try {
      setLoading(true);

      const alunoResponse = await axios.get(`${API_URL}/alunos/${matricula}`);

      setAluno(alunoResponse.data);
      const inscricoesResponse = await axios.get(`${API_URL}/alunos/${matricula}/inscricoes`);
      const inscricoesCompletas = inscricoesResponse.data;


      if (inscricoesCompletas.length > 0) {
      }
      setInscricoes(inscricoesCompletas);
      if (inscricoesCompletas.length > 0) {

        const pagamentosPromises = inscricoesCompletas.map((insc: any) =>
          axios.get(`${API_URL}/pagamentos/?inscricao_id=${insc.id_inscricao}`)
        );
        const pagamentosResponses = await Promise.all(pagamentosPromises);
        const allPagamentos = pagamentosResponses.flatMap((res: any) => res.data);

        setPagamentos(allPagamentos);
      }
    } catch (error) {
      console.error('❌ Erro ao carregar dados do aluno:', error);
      if (axios.isAxiosError(error)) {
        console.error('❌ Detalhes do erro:', error.response?.data);
      }
      Alert.alert('Erro', 'Não foi possível carregar os dados do aluno');
    } finally {
      setLoading(false);
    }
  };
  const handleDeleteAluno = async () => {
    const inscricaoParaCancelar = inscricoes.find(i =>
      i.status.toLowerCase() === 'ativa' || i.status.toLowerCase() === 'pausada'
    );
    if (!inscricaoParaCancelar) {
      setResultadoTipo('erro');
      setResultadoMensagem('Não há inscrição ativa ou pausada para cancelar.');
      setModalResultadoVisible(true);
      return;
    }
    const boletosPendentes = pagamentos.filter(p => p.status.toLowerCase() === 'pendente').length;
    const boletosAtrasados = pagamentos.filter(p => p.status.toLowerCase() === 'atrasado').length;
    setDadosCancelamento({
      inscricaoId: inscricaoParaCancelar.id_inscricao,
      boletosPendentes,
      boletosAtrasados
    });
    setModalCancelamentoVisible(true);
  };
  const confirmarCancelamento = async () => {
    if (!dadosCancelamento) return;
    setProcessandoCancelamento(true);
    try {
      const response = await axios.delete(
        `${API_URL}/inscricoes/${dadosCancelamento.inscricaoId}/cancelar`
      );

      setModalCancelamentoVisible(false);
      let sucessoMsg = 'Inscrição cancelada com sucesso!\n\n';
      if (response.data.boletos_pendentes_destruidos > 0) {
        sucessoMsg += `🗑️ ${response.data.boletos_pendentes_destruidos} boleto(s) pendente(s) cancelado(s)\n`;
      }
      if (response.data.boletos_atrasados_mantidos > 0) {
        sucessoMsg += `📋 ${response.data.boletos_atrasados_mantidos} boleto(s) atrasado(s) mantido(s) como dívida`;
      }
      setResultadoTipo('sucesso');
      setResultadoMensagem(sucessoMsg);
      setModalResultadoVisible(true);
      setTimeout(() => {
        loadAlunoData();
      }, 2000);
    } catch (error: any) {
      console.error('❌ Erro ao cancelar inscrição:', error);
      console.error('📋 Detalhes:', error.response?.data);
      setModalCancelamentoVisible(false);
      setResultadoTipo('erro');
      setResultadoMensagem(error.response?.data?.detail || 'Não foi possível cancelar a inscrição');
      setModalResultadoVisible(true);
    } finally {
      setProcessandoCancelamento(false);
    }
  };
  const handleEditarAluno = async () => {
    if (!aluno) return;



    try {
      const [planosRes, modalidadesRes] = await Promise.all([
        axios.get(`${API_URL}/planos/`),
        axios.get(`${API_URL}/planos/modalidades/`)
      ]);


      setEditNomeCompleto(aluno.nome_completo);
      setEditEmail(aluno.email);
      setEditTelefone(aluno.telefone);
      setEditCpf(aluno.cpf);
      setEditSexo(aluno.sexo);
      setEditDataNascimento(new Date(aluno.data_nascimento));
      setEditDateInputText(new Date(aluno.data_nascimento).toLocaleDateString('pt-BR'));

      let inscricaoEditavel = inscricoes.find(i => i.status.toLowerCase() === 'ativa');
      if (!inscricaoEditavel) {
        inscricaoEditavel = inscricoes.find(i => i.status.toLowerCase() === 'cancelada');

      } else {

      }

      let planoIdParaSelecionar: number | null = null;
      let modalidadesParaSelecionar: number[] = [];
      if (inscricaoEditavel) {
        setInscricaoAtivaId(inscricaoEditavel.id_inscricao);
        const planoAtual = planosRes.data.find((p: Plano) => p.nome === inscricaoEditavel.plano_nome);

        if (planoAtual) {
          planoIdParaSelecionar = planoAtual.id_plano;

        } else {
        }
        try {
          const modalidadesInscricaoRes = await axios.get(`${API_URL}/inscricoes/${inscricaoEditavel.id_inscricao}/modalidades`);
          const modalidadesAtivas = modalidadesInscricaoRes.data;
          if (modalidadesAtivas && modalidadesAtivas.length > 0) {
            modalidadesParaSelecionar = modalidadesAtivas.map((m: any) => {
              const id = Number(m.id_modalidade);
              return id;
            });

          } else {

          }
        } catch (error) {
          console.error('❌ Erro ao buscar modalidades da inscrição:', error);
          if (inscricaoEditavel.modalidades && inscricaoEditavel.modalidades.length > 0) {
            modalidadesParaSelecionar = inscricaoEditavel.modalidades.map((m: any) => m.id_modalidade);

          }
        }
      } else {
      }

      setPlanos(planosRes.data);
      setModalidades(modalidadesRes.data);
      setTimeout(() => {
        setEditPlanoSelecionado(planoIdParaSelecionar);
        setEditModalidadesSelecionadas(modalidadesParaSelecionar);







        if (planoIdParaSelecionar) {
          const planoEncontrado = planosRes.data.find((p: Plano) => p.id_plano === planoIdParaSelecionar);

          if (planoEncontrado) {


          }
        }
        if (modalidadesParaSelecionar.length > 0) {
          modalidadesParaSelecionar.forEach(idMod => {
            const modEncontrada = modalidadesRes.data.find((m: Modalidade) => m.id_modalidade === idMod);
            if (modEncontrada) {

            }
          });
        }
        setModoEdicao(true);
      }, 100);
    } catch (error) {
      console.error('❌ Erro ao carregar dados para edição:', error);
      Alert.alert('Erro', 'Não foi possível carregar os dados para edição');
    }
  };
  const handleCancelarEdicao = () => {
    setModoEdicao(false);
    setFieldErrors({});
  };
  const getMaxModalidades = (planoNome: string | undefined): number => {
    if (!planoNome) return 0;
    const nome = planoNome.toLowerCase();
    if (nome.includes('starter')) return 1;
    if (nome.includes('light')) return 2;
    if (nome.includes('premium')) return 4;
    if (nome.includes('fighter')) return 999;
    return 0;
  };
  const handleToggleModalidade = (modalidadeId: number) => {
    const planoAtual = planos.find(p => p.id_plano === editPlanoSelecionado);
    const maxModalidades = getMaxModalidades(planoAtual?.nome);
    const modalidade = modalidades.find(m => m.id_modalidade === modalidadeId);
    if (!modalidade) return;
    if (maxModalidades === 999) {
      Alert.alert(
        'Plano Fighter',
        'O plano Fighter inclui automaticamente todas as modalidades e não pode ser alterado.'
      );
      return;
    }
    if (editModalidadesSelecionadas.includes(modalidadeId)) {
      setEditModalidadesSelecionadas(editModalidadesSelecionadas.filter(id => id !== modalidadeId));
    } else {
      if (editModalidadesSelecionadas.length >= maxModalidades && maxModalidades < 999) {
        Alert.alert('Limite atingido', `Este plano permite no máximo ${maxModalidades} modalidade(s).`);
        return;
      }
      setEditModalidadesSelecionadas([...editModalidadesSelecionadas, modalidadeId]);
      if (fieldErrors.modalidades) {
        setFieldErrors(prev => ({ ...prev, modalidades: undefined }));
      }
    }
  };
  const isModalidadeDisabled = (modalidade: Modalidade): boolean => {
    if (!editPlanoSelecionado) return true;
    const planoAtual = planos.find(p => p.id_plano === editPlanoSelecionado);
    const maxModalidades = getMaxModalidades(planoAtual?.nome);
    if (maxModalidades === 999) return true;
    if (editModalidadesSelecionadas.includes(modalidade.id_modalidade)) return false;
    if (editModalidadesSelecionadas.length >= maxModalidades && maxModalidades < 999) return true;
    return false;
  };
  const validateForm = () => {
    const errors: typeof fieldErrors = {};
    let isValid = true;
    if (!editNomeCompleto.trim()) {
      errors.nomeCompleto = 'Nome completo é obrigatório';
      isValid = false;
    } else if (editNomeCompleto.split(' ').filter(n => n.length > 0).length < 2) {
      errors.nomeCompleto = 'Informe nome e sobrenome';
      isValid = false;
    }
    if (!editEmail.trim()) {
      errors.email = 'Email é obrigatório';
      isValid = false;
    } else if (!editEmail.includes('@') || !editEmail.includes('.')) {
      errors.email = 'Email inválido (ex: nome@email.com)';
      isValid = false;
    }
    const telefoneNumbers = editTelefone.replace(/\D/g, '');
    if (!editTelefone.trim()) {
      errors.telefone = 'Telefone é obrigatório';
      isValid = false;
    } else if (telefoneNumbers.length < 10) {
      errors.telefone = 'Telefone inválido (mínimo 10 dígitos)';
      isValid = false;
    }
    const cpfNumbers = editCpf.replace(/\D/g, '');
    if (!editCpf.trim()) {
      errors.cpf = 'CPF é obrigatório';
      isValid = false;
    } else if (cpfNumbers.length !== 11) {
      errors.cpf = 'CPF deve ter 11 dígitos';
      isValid = false;
    } else if (!/^\d{3}\.\d{3}\.\d{3}-\d{2}$/.test(editCpf)) {
      errors.cpf = 'CPF deve estar no formato XXX.XXX.XXX-XX';
      isValid = false;
    }
    if (!editSexo) {
      errors.sexo = 'Selecione o sexo';
      isValid = false;
    }
    const hoje = new Date();
    const idade = hoje.getFullYear() - editDataNascimento.getFullYear();
    const mesAtual = hoje.getMonth();
    const mesNasc = editDataNascimento.getMonth();
    const diaAtual = hoje.getDate();
    const diaNasc = editDataNascimento.getDate();
    let idadeReal = idade;
    if (mesAtual < mesNasc || (mesAtual === mesNasc && diaAtual < diaNasc)) {
      idadeReal--;
    }
    if (idadeReal < 16) {
      errors.dataNascimento = 'Idade mínima: 16 anos';
      isValid = false;
    }
    if (!editPlanoSelecionado) {
      errors.plano = 'Selecione um plano';
      isValid = false;
    }
    const planoAtual = planos.find(p => p.id_plano === editPlanoSelecionado);
    const maxModalidades = getMaxModalidades(planoAtual?.nome);
    if (maxModalidades < 999 && editModalidadesSelecionadas.length === 0) {
      errors.modalidades = 'Selecione pelo menos uma modalidade';
      isValid = false;
    }
    setFieldErrors(errors);
    return isValid;
  };
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
  const handleSalvarEdicao = async () => {
    if (!validateForm()) {


      Alert.alert('Atenção', 'Por favor, corrija os erros no formulário');
      return;
    }


    setLoadingSave(true);
    try {







      const sexosValidos = ['Masculino', 'Feminino', 'Outro'];
      if (!sexosValidos.includes(editSexo)) {
        console.error('❌ SEXO INVÁLIDO:', editSexo);
        Alert.alert('Erro', `Sexo inválido: ${editSexo}. Esperado: Masculino, Feminino ou Outro`);
        setLoadingSave(false);
        return;
      }
      const dataFormatada = editDataNascimento.toISOString().split('T')[0];
      const dadosAluno = {
        nome_completo: editNomeCompleto,
        email: editEmail,
        telefone: editTelefone,
        cpf: editCpf,
        sexo: editSexo,
        data_nascimento: dataFormatada
      };
      const alunoResponse = await axios.put(`${API_URL}/alunos/${matricula}`, dadosAluno);

      const inscricaoAtiva = inscricoes.find(i => i.status.toLowerCase() === 'ativa');
      const inscricaoCancelada = inscricoes.find(i => i.status.toLowerCase() === 'cancelada');
      if (inscricaoAtiva) {

        const planoAtual = planos.find(p => p.id_plano === editPlanoSelecionado);
        const planoMudou = planoAtual && inscricaoAtiva.plano_nome !== planoAtual.nome;
        if (planoMudou) {

          await axios.put(`${API_URL}/inscricoes/${inscricaoAtiva.id_inscricao}`, {
            id_plano: editPlanoSelecionado
          });
        }

        await axios.put(`${API_URL}/inscricoes/${inscricaoAtiva.id_inscricao}/modalidades`,
          editModalidadesSelecionadas
        );

      } else if (inscricaoCancelada) {

        try {
          await axios.put(`${API_URL}/inscricoes/${inscricaoCancelada.id_inscricao}`, {
            status: 'ativa'
          });

          const planoAtual = planos.find(p => p.id_plano === editPlanoSelecionado);
          const planoMudou = planoAtual && inscricaoCancelada.plano_nome !== planoAtual.nome;
          if (planoMudou) {

            await axios.put(`${API_URL}/inscricoes/${inscricaoCancelada.id_inscricao}`, {
              id_plano: editPlanoSelecionado
            });

          }

          await axios.put(`${API_URL}/inscricoes/${inscricaoCancelada.id_inscricao}/modalidades`,
            editModalidadesSelecionadas
          );

          Alert.alert(
            'Inscrição Reativada!',
            'A inscrição foi reativada com sucesso. Um novo boleto pendente foi gerado automaticamente.',
            [{ text: 'OK' }]
          );
        } catch (error: any) {
          console.error('❌ Erro ao reativar inscrição:', error);
          if (error.response?.data?.detail) {
            Alert.alert('Não é possível reativar', error.response.data.detail);
          } else {
            Alert.alert('Erro', 'Não foi possível reativar a inscrição');
          }
          setLoadingSave(false);
          return;
        }
      } else if (editPlanoSelecionado) {

        const novaInscricaoResponse = await axios.post(`${API_URL}/inscricoes/`, {
          id_aluno: matricula,
          id_plano: editPlanoSelecionado,
          data_inicio: new Date().toISOString().split('T')[0]
        });

        const novaInscricaoId = novaInscricaoResponse.data.id_inscricao;
        for (const modalidadeId of editModalidadesSelecionadas) {
          await axios.post(`${API_URL}/inscricoes/${novaInscricaoId}/modalidades/${modalidadeId}`);
        }

      }

      if (aluno) {
        setAluno({
          ...aluno,
          nome_completo: editNomeCompleto,
          email: editEmail,
          telefone: editTelefone,
          cpf: editCpf,
          sexo: editSexo,
          data_nascimento: editDataNascimento.toISOString().split('T')[0]
        });
      }
      Alert.alert('Sucesso', 'Aluno atualizado com sucesso');
      setModoEdicao(false);
      setFieldErrors({});
      setTimeout(() => {
        loadAlunoData();
      }, 500);
    } catch (error: any) {
      console.error('❌ Erro ao atualizar aluno:', error);
      console.error('📋 Detalhes do erro:', error.response?.data);
      console.error('📋 Status:', error.response?.status);
      if (error.response?.data?.detail) {
        const detail = error.response.data.detail;
        const newErrors: typeof fieldErrors = {};
        if (typeof detail === 'string') {
          if (detail.includes('Email') && detail.includes('já cadastrado')) {
            newErrors.email = 'Este email já está cadastrado';
          } else if (detail.includes('CPF') && detail.includes('já cadastrado')) {
            newErrors.cpf = 'Este CPF já está cadastrado';
          } else {
            Alert.alert('Erro', detail);
          }
        } else if (Array.isArray(detail)) {
          detail.forEach((err: any) => {
            if (err.loc && err.loc.includes('email')) {
              newErrors.email = err.msg || 'Email inválido';
            } else if (err.loc && err.loc.includes('nome_completo')) {
              newErrors.nomeCompleto = err.msg || 'Nome inválido';
            } else if (err.loc && err.loc.includes('telefone')) {
              newErrors.telefone = err.msg || 'Telefone inválido';
            } else if (err.loc && err.loc.includes('cpf')) {
              newErrors.cpf = err.msg || 'CPF inválido';
            }
          });
        }
        if (Object.keys(newErrors).length > 0) {
          setFieldErrors(newErrors);
        }
      } else {
        Alert.alert('Erro', 'Não foi possível atualizar o aluno');
      }
    } finally {
      setLoadingSave(false);
    }
  };
  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'ativa': return '#2E8B57';
      case 'pago': return '#2E8B57';
      case 'pendente': return '#FF8C00';
      case 'atrasado': return '#B22222';
      case 'cancelada': case 'cancelado': return '#888';
      case 'aguardando_pagamento': return '#FF8C00';
      default: return '#AAAAAA';
    }
  };
  const getPagamentosOrdenados = () => {
    const atrasados = pagamentos.filter(p => p.status.toLowerCase() === 'atrasado');
    const pagos = pagamentos.filter(p => p.status.toLowerCase() === 'pago');
    const outros = pagamentos.filter(p =>
      p.status.toLowerCase() !== 'atrasado' && p.status.toLowerCase() !== 'pago'
    );
    const sortByVencimento = (a: Pagamento, b: Pagamento) =>
      new Date(a.data_vencimento).getTime() - new Date(b.data_vencimento).getTime();
    const sortPagosByPagamento = (a: Pagamento, b: Pagamento) => {
      const dataA = a.data_pagamento ? new Date(a.data_pagamento).getTime() : 0;
      const dataB = b.data_pagamento ? new Date(b.data_pagamento).getTime() : 0;
      return dataB - dataA;
    };
    return [
      ...atrasados.sort(sortByVencimento),
      ...outros.sort(sortByVencimento),
      ...pagos.sort(sortPagosByPagamento)
    ];
  };
  const getDiasAtraso = (dataVencimento: string) => {
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);
    const vencimento = new Date(dataVencimento);
    vencimento.setHours(0, 0, 0, 0);
    const diffTime = hoje.getTime() - vencimento.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays > 0 ? diffDays : 0;
  };
  const handleAbrirModalPagamento = (pagamento: Pagamento) => {

    setPagamentoSelecionado(pagamento);
    setModalPagamentoVisible(true);
  };
  const handleFecharModalPagamento = () => {
    if (!processandoPagamento) {
      setModalPagamentoVisible(false);
      setPagamentoSelecionado(null);
    }
  };
  const confirmarPagamento = async () => {
    if (!pagamentoSelecionado) return;

    setProcessandoPagamento(true);
    try {
      const payload = {
        data_pagamento: new Date().toISOString().split('T')[0],
        valor_total_pago: pagamentoSelecionado.valor_total_devido.toString(),
        status: 'pago'
      };

      const response = await axios.put(
        `${API_URL}/pagamentos/${pagamentoSelecionado.id_pagamento}/pagar`,
        payload
      );

      if (response.status !== 200) {
        throw new Error(`Status inesperado: ${response.status}`);
      }
      if (response.data.status !== 'pago') {
        throw new Error('Pagamento não foi marcado como pago');
      }
      setPagamentos(prev =>
        prev.map(p =>
          p.id_pagamento === pagamentoSelecionado.id_pagamento
            ? { ...p, status: 'pago', data_pagamento: new Date().toISOString().split('T')[0] }
            : p
        )
      );
      setModalPagamentoVisible(false);
      setPagamentoSelecionado(null);
      setTimeout(() => {
        loadAlunoData();
      }, 500);
    } catch (error: any) {
      console.error('❌ Erro ao confirmar pagamento:', error);
      const mensagemErro = error.response?.data?.detail || error.message || 'Erro ao processar pagamento';
      alert(mensagemErro);
    } finally {
      setProcessandoPagamento(false);
    }
  };
  const formatCurrency = (value: number) => {
    return value.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
  };
  if (loading) {
    return (
      <View style={[styles.container, { justifyContent: 'center' }]}>
        <ActivityIndicator size="large" color="#FFD700" />
      </View>
    );
  }
  if (!aluno) {
    return (
      <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backButtonText}>{"< Voltar"}</Text>
        </TouchableOpacity>
        <Text style={styles.errorText}>Aluno não encontrado</Text>
      </SafeAreaView>
    );
  }
  return (
    <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>
      <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
        <Text style={styles.backButtonText}>{"< Voltar"}</Text>
      </TouchableOpacity>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        <View style={[styles.contentWrapper, isWeb && styles.contentWrapperWeb]}>
        {}
        <View style={styles.header}>
          <View style={styles.avatarLarge}>
            <Ionicons name="person" size={48} color="#000000" />
          </View>
          <Text style={styles.title}>{aluno.nome_completo}</Text>
          <Text style={styles.matriculaText}>Matrícula: {aluno.matricula}</Text>
        </View>
        {}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Informações Pessoais</Text>
          <View style={styles.infoCard}>
            <InfoRow label="Email" value={aluno.email} />
            <InfoRow label="Telefone" value={aluno.telefone} />
            <InfoRow label="CPF" value={aluno.cpf} />
            <InfoRow label="Sexo" value={aluno.sexo} />
            <InfoRow label="Data Nascimento" value={new Date(aluno.data_nascimento).toLocaleDateString('pt-BR')} />
            <InfoRow label="Cadastrado em" value={new Date(aluno.data_cadastro).toLocaleDateString('pt-BR')} />
          </View>
        </View>
        {}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Inscrições ({inscricoes.length})</Text>
          {inscricoes.length === 0 ? (
            <Text style={styles.emptyText}>Nenhuma inscrição encontrada</Text>
          ) : (
            inscricoes.map((inscricao) => (
              <View key={inscricao.id_inscricao} style={styles.card}>
                <View style={styles.cardHeader}>
                  <View style={styles.cardTitleContainer}>
                    <Text style={styles.cardTitle}>{inscricao.plano_nome || 'Plano não identificado'}</Text>
                    {inscricao.plano_preco && (
                      <Text style={styles.cardPrice}>R$ {Number(inscricao.plano_preco).toFixed(2)}/mês</Text>
                    )}
                  </View>
                  <View style={[styles.statusBadge, { backgroundColor: getStatusColor(inscricao.status) }]}>
                    <Text style={styles.statusText}>{inscricao.status.toUpperCase()}</Text>
                  </View>
                </View>
                <Text style={styles.cardDetail}>Início: {new Date(inscricao.data_inicio).toLocaleDateString('pt-BR')}</Text>
                {inscricao.data_fim && (
                  <Text style={styles.cardDetail}>Fim: {new Date(inscricao.data_fim).toLocaleDateString('pt-BR')}</Text>
                )}
                {}
                {inscricao.modalidades && inscricao.modalidades.length > 0 ? (
                  <View style={{ marginTop: 12, paddingTop: 12, borderTopWidth: 1, borderTopColor: '#3A3A3A' }}>
                    <Text style={{ color: '#FFD700', fontSize: 14, fontWeight: '600', marginBottom: 8 }}>
                      Modalidades ({inscricao.modalidades.length}):
                    </Text>
                    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
                      {inscricao.modalidades.map((modalidade) => (
                        <View
                          key={modalidade.id_modalidade}
                          style={{
                            flexDirection: 'row',
                            alignItems: 'center',
                            backgroundColor: '#3A3A3A',
                            paddingHorizontal: 12,
                            paddingVertical: 6,
                            borderRadius: 16,
                            borderWidth: 1,
                            borderColor: '#FFD700'
                          }}
                        >
                          <Ionicons name="fitness" size={14} color="#FFD700" style={{ marginRight: 6 }} />
                          <Text style={{ color: '#FFFFFF', fontSize: 13, fontWeight: '500' }}>
                            {modalidade.nome}
                          </Text>
                        </View>
                      ))}
                    </View>
                  </View>
                ) : (
                  <View style={{ marginTop: 12, paddingTop: 12, borderTopWidth: 1, borderTopColor: '#3A3A3A' }}>
                    <Text style={{ color: '#999999', fontSize: 13, fontStyle: 'italic' }}>
                      Nenhuma modalidade selecionada
                    </Text>
                  </View>
                )}
              </View>
            ))
          )}
        </View>
        {}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Pagamentos ({pagamentos.length})</Text>
          {pagamentos.length === 0 ? (
            <Text style={styles.emptyText}>Nenhum pagamento encontrado</Text>
          ) : (
            <>
              {getPagamentosOrdenados()
                .slice(0, mostrarTodosPagamentos ? undefined : 5)
                .map((pagamento) => {
                  const isProblematico = pagamento.status.toLowerCase() === 'atrasado';
                  const isPendente = pagamento.status.toLowerCase() === 'pendente';
                  const isPago = pagamento.status.toLowerCase() === 'pago';
                  const diasAtraso = getDiasAtraso(pagamento.data_vencimento);
                  const getCardStyle = () => {
                    if (isProblematico) {
                      return { borderLeftWidth: 4, borderLeftColor: '#B22222', backgroundColor: '#2A1A1A' };
                    }
                    if (isPendente) {
                      return { borderLeftWidth: 4, borderLeftColor: '#FF8C00', backgroundColor: '#2A2010' };
                    }
                    if (isPago) {
                      return { borderLeftWidth: 4, borderLeftColor: '#2E8B57', backgroundColor: '#1A2A1A' };
                    }
                    return {};
                  };
                  return (
                    <View
                      key={pagamento.id_pagamento}
                      style={[
                        styles.card,
                        getCardStyle()
                      ]}
                    >
                      <View style={styles.cardHeader}>
                        <Text style={[
                          styles.cardTitle,
                          (isProblematico || isPendente || isPago) && styles.cardTitleDestacado
                        ]}>
                          R$ {Number(pagamento.valor_total_devido).toFixed(2)}
                        </Text>
                        <View style={[styles.statusBadge, { backgroundColor: getStatusColor(pagamento.status) }]}>
                          <Text style={styles.statusText}>{pagamento.status.toUpperCase()}</Text>
                        </View>
                      </View>
                      <Text style={styles.cardDetail}>
                        Vencimento: {new Date(pagamento.data_vencimento).toLocaleDateString('pt-BR')}
                      </Text>
                      {diasAtraso > 0 && isProblematico && (
                        <View style={styles.atrasoContainer}>
                          <Ionicons name="alert-circle" size={16} color="#B22222" />
                          <Text style={styles.atrasoText}>
                            {diasAtraso} {diasAtraso === 1 ? 'dia' : 'dias'} de atraso
                          </Text>
                        </View>
                      )}
                      {pagamento.data_pagamento && (
                        <Text style={styles.cardDetail}>
                          Pago em: {new Date(pagamento.data_pagamento).toLocaleDateString('pt-BR')}
                        </Text>
                      )}
                      {}
                      {(isProblematico || isPendente) && (
                        <TouchableOpacity
                          style={styles.confirmarPagamentoButton}
                          onPress={() => handleAbrirModalPagamento(pagamento)}
                        >
                          <Text style={styles.confirmarPagamentoButtonText}>Confirmar Pagamento</Text>
                        </TouchableOpacity>
                      )}
                    </View>
                  );
                })}
              {pagamentos.length > 5 && (
                <TouchableOpacity
                  style={styles.verTodosButton}
                  onPress={() => setMostrarTodosPagamentos(!mostrarTodosPagamentos)}
                >
                  <Text style={styles.verTodosButtonText}>
                    {mostrarTodosPagamentos ? 'Mostrar Menos' : `Ver Todos (${pagamentos.length})`}
                  </Text>
                  <Ionicons
                    name={mostrarTodosPagamentos ? "chevron-up" : "chevron-down"}
                    size={20}
                    color="#FFD700"
                  />
                </TouchableOpacity>
              )}
            </>
          )}
        </View>
        {}
        <View style={styles.actionsContainer}>
          <TouchableOpacity style={styles.editButton} onPress={handleEditarAluno}>
            <Text style={styles.editButtonText}>Editar Aluno</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.deactivateButton} onPress={handleDeleteAluno}>
            <Text style={styles.deactivateButtonText}>Cancelar Inscrição</Text>
          </TouchableOpacity>
        </View>
        </View>
      </ScrollView>
      {}
      <Modal
        visible={modoEdicao}
        animationType="slide"
        transparent={false}
        onRequestClose={handleCancelarEdicao}
      >
        <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>
          <View style={styles.modalHeader}>
            <TouchableOpacity onPress={handleCancelarEdicao} style={styles.modalCloseButton}>
              <Ionicons name="close" size={28} color="#FFD700" />
            </TouchableOpacity>
            <Text style={styles.modalTitle}>Editar Aluno</Text>
          </View>
          <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
            <View style={[styles.contentWrapper, isWeb && styles.contentWrapperWeb]}>
              {}
              <Text style={styles.sectionTitle}>📋 Dados Pessoais</Text>
              <Text style={styles.label}>Nome Completo *</Text>
              <TextInput
                placeholder="Ex: João Silva Santos"
                value={editNomeCompleto}
                onChangeText={(text) => {
                  setEditNomeCompleto(text);
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
                value={editEmail}
                onChangeText={(text) => {
                  setEditEmail(text);
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
                value={editTelefone}
                onChangeText={(text) => {
                  const formatted = formatPhone(text);
                  setEditTelefone(formatted);
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
                value={editCpf}
                onChangeText={(text) => {
                  const formatted = formatCPF(text);
                  setEditCpf(formatted);
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
              <View style={styles.sexoButtonsContainer}>
                <TouchableOpacity
                  style={[styles.sexoButton, editSexo === 'Masculino' && styles.sexoButtonSelected]}
                  onPress={() => {
                    setEditSexo('Masculino');
                    if (fieldErrors.sexo) {
                      setFieldErrors(prev => ({ ...prev, sexo: undefined }));
                    }
                  }}
                >
                  <Ionicons name="male" size={20} color={editSexo === 'Masculino' ? '#000' : '#FFD700'} />
                  <Text style={[styles.sexoButtonText, editSexo === 'Masculino' && styles.sexoButtonTextSelected]}>
                    Masculino
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.sexoButton, editSexo === 'Feminino' && styles.sexoButtonSelected]}
                  onPress={() => {
                    setEditSexo('Feminino');
                    if (fieldErrors.sexo) {
                      setFieldErrors(prev => ({ ...prev, sexo: undefined }));
                    }
                  }}
                >
                  <Ionicons name="female" size={20} color={editSexo === 'Feminino' ? '#000' : '#FFD700'} />
                  <Text style={[styles.sexoButtonText, editSexo === 'Feminino' && styles.sexoButtonTextSelected]}>
                    Feminino
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.sexoButton, editSexo === 'Outro' && styles.sexoButtonSelected]}
                  onPress={() => {
                    setEditSexo('Outro');
                    if (fieldErrors.sexo) {
                      setFieldErrors(prev => ({ ...prev, sexo: undefined }));
                    }
                  }}
                >
                  <Ionicons name="person" size={20} color={editSexo === 'Outro' ? '#000' : '#FFD700'} />
                  <Text style={[styles.sexoButtonText, editSexo === 'Outro' && styles.sexoButtonTextSelected]}>
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
                onPress={() => setShowEditDatePicker(true)}
                style={[styles.dateButton, fieldErrors.dataNascimento && styles.inputError]}
                activeOpacity={0.7}
              >
                <Ionicons name="calendar-outline" size={20} color="#FFD700" />
                <Text style={styles.dateText}>{editDataNascimento.toLocaleDateString('pt-BR')}</Text>
              </TouchableOpacity>
              {fieldErrors.dataNascimento && (
                <View style={styles.errorContainer}>
                  <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
                  <Text style={styles.fieldErrorText}>{fieldErrors.dataNascimento}</Text>
                </View>
              )}
              {Platform.OS === 'web' ? (
                <Modal
                  visible={showEditDatePicker}
                  transparent={true}
                  animationType="fade"
                  onRequestClose={() => setShowEditDatePicker(false)}
                >
                  <View style={styles.modalOverlay}>
                    <View style={styles.modalContent}>
                      <Text style={styles.modalTitle}>Selecione a Data de Nascimento</Text>
                      <TextInput
                        style={styles.dateInput}
                        value={editDateInputText}
                        onChangeText={(text) => {
                          setEditDateInputText(text);
                          const dateStr = text.replace(/[^\d/]/g, '');
                          if (dateStr.match(/^\d{2}\/\d{2}\/\d{4}$/)) {
                            try {
                              const [day, month, year] = dateStr.split('/').map(Number);
                              const newDate = new Date(year, month - 1, day);
                              if (newDate.getFullYear() === year &&
                                  newDate.getMonth() === month - 1 &&
                                  newDate.getDate() === day) {
                                setEditDataNascimento(newDate);
                                if (fieldErrors.dataNascimento) {
                                  setFieldErrors(prev => ({ ...prev, dataNascimento: undefined }));
                                }
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
                        {editDataNascimento.toLocaleDateString('pt-BR', {
                          weekday: 'long',
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric'
                        })}
                      </Text>
                      <View style={styles.modalButtonsRow}>
                        <TouchableOpacity
                          style={[styles.modalButton, { backgroundColor: '#3A3A3A', flex: 1 }]}
                          onPress={() => setShowEditDatePicker(false)}
                        >
                          <Text style={[styles.modalButtonText, { color: '#FFF' }]}>Cancelar</Text>
                        </TouchableOpacity>
                        <TouchableOpacity
                          style={[styles.modalButton, { flex: 1 }]}
                          onPress={() => setShowEditDatePicker(false)}
                        >
                          <Text style={styles.modalButtonText}>Confirmar</Text>
                        </TouchableOpacity>
                      </View>
                    </View>
                  </View>
                </Modal>
              ) : (
                showEditDatePicker && (
                  <DateTimePicker
                    value={editDataNascimento}
                    mode="date"
                    display={Platform.OS === 'ios' ? 'spinner' : 'default'}
                    onChange={(event, selectedDate) => {
                      setShowEditDatePicker(false);
                      if (selectedDate) {
                        setEditDataNascimento(selectedDate);
                        setEditDateInputText(selectedDate.toLocaleDateString('pt-BR'));
                        if (fieldErrors.dataNascimento) {
                          setFieldErrors(prev => ({ ...prev, dataNascimento: undefined }));
                        }
                      }
                    }}
                    maximumDate={new Date()}
                    minimumDate={new Date(1920, 0, 1)}
                  />
                )
              )}
              {}
              <Text style={styles.sectionTitle}>💎 Plano e Modalidades</Text>
              {}
              <View style={{ backgroundColor: '#1A1A1A', padding: 10, marginHorizontal: 20, marginBottom: 10, borderRadius: 8, borderWidth: 1, borderColor: '#FFD700' }}>
                <Text style={{ color: '#FFD700', fontSize: 12, fontWeight: 'bold' }}>🔍 DEBUG:</Text>
                <Text style={{ color: '#FFF', fontSize: 11 }}>Planos carregados: {planos.length}</Text>
                <Text style={{ color: '#FFF', fontSize: 11 }}>Modalidades carregadas: {modalidades.length}</Text>
                <Text style={{ color: '#FFF', fontSize: 11 }}>Plano selecionado ID: {editPlanoSelecionado || 'nenhum'}</Text>
                <Text style={{ color: '#FFF', fontSize: 11 }}>Modalidades selecionadas: [{editModalidadesSelecionadas.join(', ')}]</Text>
              </View>
              <Text style={styles.label}>Plano *</Text>
              <View style={styles.planosContainer}>
                {planos.length === 0 && (
                  <Text style={{ color: '#FF6B6B', padding: 10 }}>
                    ⚠️ Nenhum plano carregado
                  </Text>
                )}
                {planos.map((plano) => {
                  const planoIdNumber = Number(plano.id_plano);
                  const editPlanoNumber = editPlanoSelecionado ? Number(editPlanoSelecionado) : null;
                  const isSelected = editPlanoNumber !== null && planoIdNumber === editPlanoNumber;
                  if (plano.nome === 'Starter' || plano.nome === 'Premium') {

                  }
                  return (
                  <TouchableOpacity
                    key={plano.id_plano}
                    style={[
                      styles.planoCard,
                      isSelected && styles.planoCardSelected
                    ]}
                    onPress={() => {
                      setEditPlanoSelecionado(plano.id_plano);
                      if (plano.nome.toLowerCase().includes('fighter')) {
                        const todasModalidadesIds = modalidades.map(m => m.id_modalidade);
                        setEditModalidadesSelecionadas(todasModalidadesIds);
                      } else {
                        setEditModalidadesSelecionadas([]);
                      }
                      if (fieldErrors.plano) {
                        setFieldErrors(prev => ({ ...prev, plano: undefined }));
                      }
                    }}
                  >
                    <View style={styles.planoHeader}>
                      <Text style={[
                        styles.planoNome,
                        editPlanoSelecionado === plano.id_plano && styles.planoNomeSelected
                      ]}>
                        {plano.nome}
                      </Text>
                      {editPlanoSelecionado === plano.id_plano && (
                        <Ionicons name="checkmark-circle" size={24} color="#FFD700" />
                      )}
                    </View>
                    <Text style={styles.planoPreco}>
                      R$ {Number(plano.preco_mensal).toFixed(2)}/mês
                    </Text>
                    <Text style={styles.planoDescricao}>
                      {getMaxModalidades(plano.nome) === 999
                        ? 'Todas as modalidades'
                        : `Escolha até ${getMaxModalidades(plano.nome)} modalidade(s)`}
                    </Text>
                  </TouchableOpacity>
                  );
                })}
              </View>
              {fieldErrors.plano && (
                <View style={styles.errorContainer}>
                  <Ionicons name="alert-circle" size={16} color="#FF6B6B" />
                  <Text style={styles.fieldErrorText}>{fieldErrors.plano}</Text>
                </View>
              )}
              {}
              {editPlanoSelecionado && (
                  <View style={{ marginTop: 20 }}>
                    <Text style={styles.label}>
                      Modalidades *
                      {editModalidadesSelecionadas.length > 0 &&
                        ` (${editModalidadesSelecionadas.length} selecionada(s))`
                      }
                    </Text>
                    {}
                    <View>
                      <View style={styles.modalidadesContainer}>
                        {modalidades.map((modalidade) => {
                          const modalidadeIdNumber = Number(modalidade.id_modalidade);
                          const editModalidadesNumbers = editModalidadesSelecionadas.map(id => Number(id));
                          const isSelected = editModalidadesNumbers.includes(modalidadeIdNumber);
                          const isDisabled = isModalidadeDisabled(modalidade);
                          return (
                            <TouchableOpacity
                              key={modalidade.id_modalidade}
                              style={[
                                styles.modalidadeCard,
                                isSelected && styles.modalidadeCardSelected,
                                isDisabled && styles.modalidadeCardDisabled
                              ]}
                              onPress={() => handleToggleModalidade(modalidade.id_modalidade)}
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
              )}
              {}
              <View style={styles.buttonRow}>
                <TouchableOpacity
                  style={[styles.button, styles.cancelButtonAlt]}
                  onPress={handleCancelarEdicao}
                  disabled={loadingSave}
                >
                  <Text style={styles.cancelButtonTextAlt}>Cancelar</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.button, styles.submitButton]}
                  onPress={handleSalvarEdicao}
                  disabled={loadingSave}
                >
                  {loadingSave ? (
                    <ActivityIndicator size="small" color="#000000" />
                  ) : (
                    <Text style={styles.buttonText}>Salvar Alterações</Text>
                  )}
                </TouchableOpacity>
              </View>
            </View>
          </ScrollView>
        </SafeAreaView>
      </Modal>
      {}
      <Modal
        visible={modalPagamentoVisible}
        transparent
        animationType="fade"
        onRequestClose={handleFecharModalPagamento}
      >
        <View style={styles.modalPagamentoOverlay}>
          <View style={styles.modalPagamentoContent}>
            <View style={styles.modalPagamentoHeader}>
              <Ionicons name="alert-circle" size={48} color="#FFD700" />
              <Text style={styles.modalPagamentoTitle}>Confirmar Pagamento</Text>
            </View>
            {pagamentoSelecionado && (
              <View style={styles.modalPagamentoBody}>
                <Text style={styles.modalPagamentoText}>
                  Confirmar que <Text style={styles.modalPagamentoTextBold}>{aluno?.nome_completo}</Text> realizou o pagamento de:
                </Text>
                <Text style={styles.modalPagamentoValor}>
                  {formatCurrency(pagamentoSelecionado.valor_total_devido)}
                </Text>
                <Text style={styles.modalPagamentoInfo}>
                  Vencimento: {new Date(pagamentoSelecionado.data_vencimento).toLocaleDateString('pt-BR')}
                </Text>
              </View>
            )}
            <View style={styles.modalPagamentoActions}>
              <TouchableOpacity
                style={[styles.modalPagamentoButton, styles.modalPagamentoButtonCancel]}
                onPress={handleFecharModalPagamento}
                disabled={processandoPagamento}
              >
                <Text style={styles.modalPagamentoButtonTextCancel}>Cancelar</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalPagamentoButton, styles.modalPagamentoButtonConfirm]}
                onPress={confirmarPagamento}
                disabled={processandoPagamento}
              >
                {processandoPagamento ? (
                  <ActivityIndicator size="small" color="#FFFFFF" />
                ) : (
                  <Text style={styles.modalPagamentoButtonTextConfirm}>Confirmar</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
      {}
      <Modal
        visible={modalCancelamentoVisible}
        transparent
        animationType="fade"
        onRequestClose={() => !processandoCancelamento && setModalCancelamentoVisible(false)}
      >
        <View style={styles.modalPagamentoOverlay}>
          <View style={styles.modalCancelamentoContent}>
            <View style={styles.modalCancelamentoHeader}>
              <Ionicons name="warning" size={56} color="#FF6B6B" />
              <Text style={styles.modalCancelamentoTitle}>Cancelar Inscrição</Text>
            </View>
            <View style={styles.modalCancelamentoBody}>
              <Text style={styles.modalCancelamentoText}>
                Deseja realmente cancelar a inscrição de{' '}
                <Text style={styles.modalCancelamentoTextBold}>{aluno?.nome_completo}</Text>?
              </Text>
              {dadosCancelamento && (
                <View style={styles.modalCancelamentoInfo}>
                  {dadosCancelamento.boletosPendentes > 0 && (
                    <View style={styles.modalCancelamentoInfoRow}>
                      <Ionicons name="trash" size={20} color="#FF6B6B" />
                      <Text style={styles.modalCancelamentoInfoText}>
                        {dadosCancelamento.boletosPendentes} boleto(s) pendente(s) será(ão) cancelado(s)
                      </Text>
                    </View>
                  )}
                  {dadosCancelamento.boletosAtrasados > 0 && (
                    <View style={styles.modalCancelamentoInfoRow}>
                      <Ionicons name="document-text" size={20} color="#FFA500" />
                      <Text style={styles.modalCancelamentoInfoText}>
                        {dadosCancelamento.boletosAtrasados} boleto(s) atrasado(s) será(ão) mantido(s) como dívida
                      </Text>
                    </View>
                  )}
                  {dadosCancelamento.boletosPendentes === 0 && dadosCancelamento.boletosAtrasados === 0 && (
                    <View style={styles.modalCancelamentoInfoRow}>
                      <Ionicons name="checkmark-circle" size={20} color="#2E8B57" />
                      <Text style={styles.modalCancelamentoInfoText}>
                        Nenhuma pendência encontrada
                      </Text>
                    </View>
                  )}
                </View>
              )}
            </View>
            <View style={styles.modalCancelamentoActions}>
              <TouchableOpacity
                style={[styles.modalCancelamentoButton, styles.modalCancelamentoButtonCancel]}
                onPress={() => setModalCancelamentoVisible(false)}
                disabled={processandoCancelamento}
              >
                <Text style={styles.modalCancelamentoButtonTextCancel}>Não</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalCancelamentoButton, styles.modalCancelamentoButtonConfirm]}
                onPress={confirmarCancelamento}
                disabled={processandoCancelamento}
              >
                {processandoCancelamento ? (
                  <ActivityIndicator size="small" color="#FFFFFF" />
                ) : (
                  <Text style={styles.modalCancelamentoButtonTextConfirm}>Sim, Cancelar</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
      {}
      <Modal
        visible={modalResultadoVisible}
        transparent
        animationType="fade"
        onRequestClose={() => setModalResultadoVisible(false)}
      >
        <View style={styles.modalPagamentoOverlay}>
          <View style={styles.modalResultadoContent}>
            <View style={styles.modalResultadoHeader}>
              <Ionicons
                name={resultadoTipo === 'sucesso' ? 'checkmark-circle' : 'close-circle'}
                size={64}
                color={resultadoTipo === 'sucesso' ? '#2E8B57' : '#FF6B6B'}
              />
              <Text style={[
                styles.modalResultadoTitle,
                resultadoTipo === 'erro' && styles.modalResultadoTitleErro
              ]}>
                {resultadoTipo === 'sucesso' ? 'Sucesso!' : 'Erro'}
              </Text>
            </View>
            <View style={styles.modalResultadoBody}>
              <Text style={styles.modalResultadoText}>{resultadoMensagem}</Text>
            </View>
            <TouchableOpacity
              style={[
                styles.modalResultadoButton,
                resultadoTipo === 'erro' && styles.modalResultadoButtonErro
              ]}
              onPress={() => setModalResultadoVisible(false)}
            >
              <Text style={styles.modalResultadoButtonText}>OK</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
      <StatusBar style="light" />
    </SafeAreaView>
  );
}
function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.infoRow}>
      <Text style={styles.infoLabel}>{label}:</Text>
      <Text style={styles.infoValue}>{value}</Text>
    </View>
  );
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212'
  },
  contentWrapper: {
    width: '100%',
  },
  contentWrapperWeb: {
    maxWidth: 1000,
    alignSelf: 'center',
  },
  backButton: {
    position: 'absolute',
    top: 10,
    left: 16,
    zIndex: 1,
    backgroundColor: '#282828',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
  },
  backButtonText: {
    color: '#FFD700',
    fontSize: 16,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: 40,
  },
  header: {
    alignItems: 'center',
    paddingTop: 70,
    paddingBottom: 24,
    paddingHorizontal: 20,
  },
  avatarLarge: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#FFD700',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
    elevation: 6,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 8,
  },
  title: {
    fontSize: 26,
    fontWeight: '800',
    color: '#FFFFFF',
    textAlign: 'center',
    marginBottom: 10,
    letterSpacing: 0.5,
  },
  matriculaText: {
    fontSize: 15,
    color: '#FFD700',
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  section: {
    paddingHorizontal: 20,
    marginBottom: 28,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#FFD700',
    marginTop: 24,
    marginBottom: 16,
    paddingHorizontal: 20,
    letterSpacing: 0.5,
  },
  infoCard: {
    backgroundColor: '#282828',
    borderRadius: 16,
    padding: 20,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.25,
    shadowRadius: 5,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#3A3A3A',
  },
  infoLabel: {
    color: '#AAAAAA',
    fontSize: 15,
    fontWeight: '600',
  },
  infoValue: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '600',
    letterSpacing: 0.3,
  },
  card: {
    backgroundColor: '#282828',
    borderRadius: 16,
    padding: 18,
    marginBottom: 14,
    borderWidth: 1,
    borderColor: '#3A3A3A',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.25,
    shadowRadius: 5,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  cardTitleContainer: {
    flex: 1,
    marginRight: 12,
  },
  cardTitle: {
    color: '#FFFFFF',
    fontSize: 17,
    fontWeight: '700',
    letterSpacing: 0.3,
    marginBottom: 4,
  },
  cardPrice: {
    color: '#FFD700',
    fontSize: 14,
    fontWeight: '600',
    letterSpacing: 0.3,
  },
  cardDestacado: {
    borderLeftWidth: 4,
    borderLeftColor: '#B22222',
    backgroundColor: '#2A1A1A',
  },
  cardTitleDestacado: {
    color: '#FFD700',
  },
  modalidadesListContainer: {
    marginVertical: 12,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#3A3A3A',
  },
  modalidadesLabel: {
    color: '#AAAAAA',
    fontSize: 13,
    fontWeight: '600',
    marginBottom: 8,
    letterSpacing: 0.3,
  },
  modalidadesList: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  modalidadeBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#3A3A3A',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
    gap: 6,
  },
  modalidadeText: {
    color: '#FFD700',
    fontSize: 13,
    fontWeight: '600',
    letterSpacing: 0.3,
  },
  atrasoContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
    gap: 6,
  },
  atrasoText: {
    color: '#B22222',
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 0.3,
  },
  verTodosButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#282828',
    paddingVertical: 14,
    borderRadius: 12,
    marginTop: 12,
    borderWidth: 1,
    borderColor: '#FFD700',
    gap: 8,
    elevation: 2,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
  },
  verTodosButtonText: {
    color: '#FFD700',
    fontSize: 15,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  statusBadge: {
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 16,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
  },
  statusText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  cardDetail: {
    color: '#CCCCCC',
    fontSize: 14,
    marginTop: 6,
    fontWeight: '500',
  },
  emptyText: {
    color: '#888',
    textAlign: 'center',
    fontSize: 15,
    marginTop: 12,
    fontWeight: '500',
  },
  actionsContainer: {
    flexDirection: 'row',
    gap: 12,
    marginHorizontal: 20,
    marginTop: 24,
  },
  editButton: {
    flex: 1,
    backgroundColor: '#FFD700',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 8,
    elevation: 4,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 6,
  },
  editButtonText: {
    color: '#000000',
    fontSize: 16,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  deactivateButton: {
    flex: 1,
    backgroundColor: '#B22222',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 8,
    elevation: 4,
    shadowColor: '#B22222',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 6,
  },
  deactivateButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  modalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#3A3A3A',
    backgroundColor: '#282828',
  },
  modalCloseButton: {
    padding: 8,
    marginRight: 12,
  },
  modalTitle: {
    fontSize: 22,
    fontWeight: '700',
    color: '#FFD700',
    letterSpacing: 0.5,
  },
  formGroup: {
    marginBottom: 20,
    paddingHorizontal: 20,
  },
  label: {
    color: '#FFD700',
    fontSize: 15,
    fontWeight: '700',
    marginBottom: 8,
    letterSpacing: 0.3,
  },
  input: {
    backgroundColor: '#282828',
    borderWidth: 1,
    borderColor: '#3A3A3A',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '500',
  },
  inputError: {
    borderColor: '#FF6B6B',
    marginBottom: 8,
  },
  errorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
    paddingLeft: 4,
    gap: 6,
  },
  fieldErrorText: {
    color: '#FF6B6B',
    fontSize: 13,
    fontWeight: '600',
  },
  pickerContainer: {
    backgroundColor: '#282828',
    borderWidth: 1,
    borderColor: '#3A3A3A',
    borderRadius: 12,
    overflow: 'hidden',
  },
  pickerInput: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '500',
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: 'transparent',
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
  dateButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '500',
  },
  modalidadesGrid: {
    gap: 12,
  },
  modalidadeChip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#282828',
    borderWidth: 1,
    borderColor: '#3A3A3A',
    borderRadius: 12,
    padding: 14,
    gap: 12,
  },
  modalidadeChipSelected: {
    borderColor: '#FFD700',
    backgroundColor: '#2A2A1A',
  },
  modalidadeChipDisabled: {
    opacity: 0.4,
  },
  modalidadeChipTextContainer: {
    flex: 1,
  },
  modalidadeChipText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '600',
    marginBottom: 2,
  },
  modalidadeChipTextSelected: {
    color: '#FFD700',
  },
  modalidadeChipTextDisabled: {
    color: '#555',
  },
  modalidadeChipCategory: {
    color: '#AAAAAA',
    fontSize: 12,
    fontWeight: '500',
  },
  modalActions: {
    flexDirection: 'row',
    gap: 12,
    marginHorizontal: 20,
    marginTop: 32,
    marginBottom: 40,
  },
  planosContainer: {
    gap: 12,
    marginBottom: 20,
    paddingHorizontal: 20,
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
    paddingHorizontal: 20,
  },
  modalidadesContainer: {
    gap: 10,
    marginBottom: 12,
    paddingHorizontal: 20,
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
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
    marginHorizontal: 20,
    marginTop: 32,
    marginBottom: 40,
  },
  button: {
    flex: 1,
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 8,
  },
  submitButton: {
    backgroundColor: '#FFD700',
    elevation: 4,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  buttonText: {
    color: '#000000',
    fontSize: 16,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  cancelButtonAlt: {
    backgroundColor: '#3A3A3A',
    borderWidth: 1,
    borderColor: '#555',
  },
  cancelButtonTextAlt: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  cancelButton: {
    flex: 1,
    backgroundColor: '#3A3A3A',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    elevation: 2,
  },
  cancelButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  saveButton: {
    flex: 1,
    backgroundColor: '#FFD700',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 8,
    elevation: 4,
    shadowColor: '#FFD700',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.4,
    shadowRadius: 4,
  },
  saveButtonText: {
    color: '#000000',
    fontSize: 16,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  sexoButtonsContainer: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 16,
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
  dateText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '500',
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
  dateHelp: {
    color: '#AAA',
    fontSize: 12,
    marginBottom: 12,
    textAlign: 'center',
  },
  datePreview: {
    color: '#FFFFFF',
    fontSize: 14,
    marginBottom: 16,
    textAlign: 'center',
    fontStyle: 'italic',
  },
  modalButtonsRow: {
    flexDirection: 'row',
    gap: 12,
    width: '100%',
  },
  errorText: {
    color: '#B22222',
    fontSize: 20,
    textAlign: 'center',
    marginTop: 120,
    fontWeight: '700',
    paddingHorizontal: 40,
  },
  confirmarPagamentoButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2E8B57',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 10,
    marginTop: 12,
    gap: 8,
    elevation: 3,
    shadowColor: '#2E8B57',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.4,
    shadowRadius: 5,
  },
  confirmarPagamentoButtonText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  modalPagamentoOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalPagamentoContent: {
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
  modalPagamentoHeader: {
    alignItems: 'center',
    marginBottom: 20,
  },
  modalPagamentoTitle: {
    fontSize: 24,
    fontWeight: '700',
    color: '#FFFFFF',
    marginTop: 12,
    letterSpacing: 0.5,
  },
  modalPagamentoBody: {
    marginBottom: 24,
  },
  modalPagamentoText: {
    fontSize: 16,
    color: '#CCCCCC',
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 16,
  },
  modalPagamentoTextBold: {
    fontWeight: '700',
    color: '#FFFFFF',
  },
  modalPagamentoValor: {
    fontSize: 32,
    fontWeight: '800',
    color: '#FFD700',
    textAlign: 'center',
    marginBottom: 12,
    letterSpacing: 1,
  },
  modalPagamentoInfo: {
    fontSize: 14,
    color: '#AAAAAA',
    textAlign: 'center',
  },
  modalPagamentoActions: {
    flexDirection: 'row',
    gap: 12,
  },
  modalPagamentoButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 2,
  },
  modalPagamentoButtonCancel: {
    backgroundColor: '#3A3A3A',
  },
  modalPagamentoButtonConfirm: {
    backgroundColor: '#2E8B57',
  },
  modalPagamentoButtonTextCancel: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  modalPagamentoButtonTextConfirm: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.85)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalCancelamentoContent: {
    backgroundColor: '#1E1E1E',
    borderRadius: 16,
    padding: 24,
    width: '100%',
    maxWidth: 500,
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  modalCancelamentoHeader: {
    alignItems: 'center',
    marginBottom: 20,
  },
  modalCancelamentoTitle: {
    fontSize: 24,
    fontWeight: '700',
    color: '#FF6B6B',
    marginTop: 12,
    letterSpacing: 0.5,
  },
  modalCancelamentoBody: {
    marginBottom: 24,
  },
  modalCancelamentoText: {
    fontSize: 16,
    color: '#CCCCCC',
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 16,
  },
  modalCancelamentoTextBold: {
    fontWeight: '700',
    color: '#FFFFFF',
  },
  modalCancelamentoInfo: {
    backgroundColor: '#282828',
    borderRadius: 12,
    padding: 16,
    gap: 12,
  },
  modalCancelamentoInfoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  modalCancelamentoInfoText: {
    flex: 1,
    fontSize: 14,
    color: '#CCCCCC',
    lineHeight: 20,
  },
  modalCancelamentoActions: {
    flexDirection: 'row',
    gap: 12,
  },
  modalCancelamentoButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 2,
  },
  modalCancelamentoButtonCancel: {
    backgroundColor: '#3A3A3A',
  },
  modalCancelamentoButtonConfirm: {
    backgroundColor: '#DC3545',
  },
  modalCancelamentoButtonTextCancel: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  modalCancelamentoButtonTextConfirm: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },
  modalResultadoContent: {
    backgroundColor: '#1E1E1E',
    borderRadius: 16,
    padding: 24,
    width: '100%',
    maxWidth: 400,
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  modalResultadoHeader: {
    alignItems: 'center',
    marginBottom: 20,
  },
  modalResultadoTitle: {
    fontSize: 24,
    fontWeight: '700',
    color: '#2E8B57',
    marginTop: 12,
    letterSpacing: 0.5,
  },
  modalResultadoTitleErro: {
    color: '#FF6B6B',
  },
  modalResultadoBody: {
    marginBottom: 24,
  },
  modalResultadoText: {
    fontSize: 15,
    color: '#CCCCCC',
    textAlign: 'center',
    lineHeight: 22,
  },
  modalResultadoButton: {
    backgroundColor: '#2E8B57',
    paddingVertical: 14,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 2,
  },
  modalResultadoButtonErro: {
    backgroundColor: '#FF6B6B',
  },
  modalResultadoButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },
});
