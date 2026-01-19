# MediTime 2.0 💊

**Gerenciador de Medicamentos Inteligente para Idosos.**

## Novidades na Versão 2.0
- **Estoque Inteligente**: Alertas precisos ("FALTAM 20 doses") baseados na duração do tratamento.
- **Calendário Visual**: Cada remédio tem uma cor única (Pastel) para fácil identificação no calendário.
- **UX Acessível**: Campos maiores (55px+), fontes legíveis e validações claras.

## Funcionalidades Principais
1.  **Login Simplificado**: Acesso via Email/Senha ou Convidado (Anônimo).
2.  **Cadastro Completo**:
    - Foto da receita/embalagem.
    - Agendamento (Horários fixos ou Intervalos).
    - Controle de estoque (Total + Qtd/Dose).
3.  **Monitoramento**:
    - **Lista**: Cards com bordas coloridas e badges de estoque (Vermelho/Verde).
    - **Calendário**: Visualização mensal com "dots" coloridos por dia.
4.  **Acessibilidade**: Design focado em alto contraste e facilidade de toque.

## Instalação e Execução

### Requisitos
- Flutter SDK 3.27+
- Dispositivo Android, iOS ou Navegador (Chrome/Edge).

### Comandos
```bash
# Instalar dependências
flutter pub get

# Rodar no Web (Chrome)
flutter run -d chrome --web-port=8088

# Rodar no Android
flutter run -d android
```

## Credenciais de Teste
Para verificação completa das funcionalidades:
- **Email**: `teste@gmail.com`
- **Senha**: `123456`

## Estrutura do Projeto
- `lib/screens`: Telas (Login, Lista, Cadastro, Calendário).
- `lib/data`: Banco de dados e Modelos.
- `lib/providers`: Gerenciamento de estado (Riverpod).
