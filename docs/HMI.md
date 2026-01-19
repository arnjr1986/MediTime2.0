# Human-Machine Interface (MediTime HMI)

## User Flows

### 1. Adicionar Medicamento (Novo Fluxo de Estoque)
1.  **Tela Inicial**: Clicar no botão (+).
2.  **Formulário**:
    - Preencher Nome, Dosagem.
    - **Estoque**: Inserir "Qtd Total" e "Qtd/Dose".
    - **Obs**: Ver caixa azul "Estimativa" aparecer em tempo real.
    - **Cor**: O sistema atribui uma cor pastel automaticamente.
3.  **Salvar**: Clicar em "SALVAR RECEITA".
4.  **Resultado**: O card aparece na lista com a badge de estoque.

### 2. Verificar Calendário (Novo Fluxo Visual)
1.  **Dashboard**: Clicar no ícone de Calendário (Barra inferior).
2.  **Visualização**:
    - Dias com remédios têm "dots" coloridos.
    - A cor do dot corresponde à cor do medicamento na Lista.
3.  **Seleção**: Clicar em um dia exibe a lista detalhada abaixo.

## Screenshots

### Lista de Medicamentos (Alertas de Estoque)
Visualização clara dos badges de estoque ("FALTAM 20!"). A cor lateral indica a identidade visual do remédio.

![Stock Alert Badge](file:///C:/Users/Arn/.gemini/antigravity/brain/39c263f4-578e-4032-8f00-019b374eb70b/meds_list_stock_1768808607918.png)

### Calendário (Visualização Mensal)
Integração de cores para fácil leitura rápida.

![Calendar View](file:///C:/Users/Arn/.gemini/antigravity/brain/39c263f4-578e-4032-8f00-019b374eb70b/calendar_view_1768808691726.png)

## Regras de UX
- **Tamanho de Toque**: Botões e Inputs com altura mínima de 55px.
- **Feedback**: Snackbars para ações (Salvar, Tomar Dose).
- **Cores**: Semânticas para estoque (Vermelho=Crítico, Verde=Ok), Pastel para identidade.
