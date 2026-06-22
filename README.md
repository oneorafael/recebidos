# Recebidos?

Aplicativo iOS para ajudar profissionais autônomos a acompanhar cobranças e lembrar clientes sobre pagamentos pendentes.

O projeto foi desenvolvido como atividade de extensão da disciplina **Inteligência Artificial para Devs**. A proposta surgiu a partir da dificuldade de profissionais do audiovisual em organizar prazos e escrever mensagens de cobrança claras e respeitosas.

## Evidências

### Capturas de tela

<img width="1194" height="834" alt="Tela do aplicativo Recebidos" src="https://github.com/user-attachments/assets/ca029b66-92ef-423a-a8dd-bb85f30afb7b" />
<img width="1194" height="834" alt="Tela do aplicativo Recebidos" src="https://github.com/user-attachments/assets/f97afdf3-3122-4d28-aed1-7cba175b7234" />
<img width="1194" height="834" alt="Tela do aplicativo Recebidos" src="https://github.com/user-attachments/assets/bce36bcd-af55-44e1-93c2-738f5af8a088" />
<img width="1194" height="834" alt="Tela do aplicativo Recebidos" src="https://github.com/user-attachments/assets/341cb586-1cb3-4567-8214-d2ca62fa613f" />

## Funcionalidades

- Cadastro de clientes, projetos, valores e prazos de pagamento.
- Controle de cobranças recebidas e pendentes.
- Armazenamento local dos dados do aplicativo.
- Notificações locais às 9h na data de vencimento.
- Geração de mensagens de cobrança em diferentes tons.
- Compartilhamento da mensagem gerada.

## Inteligência artificial

O aplicativo utiliza o framework **Foundation Models** da Apple para gerar mensagens no próprio dispositivo. Os dados do cliente e do profissional são usados como contexto, sem depender de uma API externa.

Quando o modelo local não está disponível, o aplicativo apresenta uma mensagem padrão para que a funcionalidade principal continue funcionando.

## Tecnologias

- Swift
- SwiftUI
- Foundation Models
- UserNotifications
- Observation
- UserDefaults com Codable

## Requisitos

- Xcode compatível com o SDK do iOS 26
- iOS 26 ou posterior
- Dispositivo compatível com Apple Intelligence para a geração por IA (`iPhone 15 Pro` ou superior)

## Guia

- Documentação oficial do Foundation Models: https://developer.apple.com/documentation/foundationmodels

## Execução

1. Abra `Recebidos?.xcodeproj` no Xcode.
2. Selecione um simulador ou dispositivo compatível.
3. Execute o projeto com `Command + R`.

As demais funções do aplicativo podem ser testadas no simulador. A geração com Foundation Models depende de um dispositivo compatível e da disponibilidade do modelo local.
