# Ultima Saida - survival horror 3D para Lupi

Prototipo 0.4 independente do jogo de corrida. Uma sala de deposito, um personagem, um inimigo, uma chave e uma porta de fuga. Camera obliqua mais proxima, com orientacao fixa e posicao acompanhando o jogador; malhas XYZ projetadas em perspectiva e rasterizadas com ui.trisfill. Sem raycasting 2,5D, texturas ou sombras dinamicas.

## Como jogar

- B: iniciar / correr segurando cima ou baixo.
- Cruz cima/baixo: avancar e recuar; esquerda/direita: girar o personagem (controle classico).
- A: interagir perto da chave amarela ou da porta verde.
- R: disparar na direcao do personagem. Tres tiros; acertos atordoam por tres segundos. Mesas bloqueiam tiros (volume simplificado).
- Y: reiniciar. Na tela final B tambem reinicia.

Pegue a chave no fundo esquerdo da sala e abra a porta verde. O inimigo causa dano por contato; o personagem tem tres pontos de vida. O inimigo usa perseguicao simples com colisao e pode ficar preso em mesas; nao ha navegacao completa nesta versao.

## Instalar

O ZIP de teste tem game.lua e lupi.yaml na raiz. Instale pelo mesmo fluxo de importacao de jogos usado na corrida. Nao substitua o projeto da corrida. Repositorio: https://github.com/onomevaiaqui/ofarol. Metadados com public: true para descoberta pelo catalogo do Lupi.

## Limites e verificacao

- Tela 480x270, paleta 32 cores BGR555, sem assets externos.
- Malhas originais simples; renderer.lua, geometry.lua e colors.lua copiados da base de corrida sem modificar a origem.
- 192 entradas no pool reutilizavel de triangulos; recorte proximo e na tela, backface culling, coordenadas inteiras e painter sort. Sem z-buffer.
- Cena: 309 triangulos de entrada (incluindo chave e atores); pico amostrado: 180 triangulos nativos visiveis. O numero exibido e calculado por quadro.
- O teste no computador utiliza 24 FPS simulados apenas para dt. Esse valor NAO mede nem promete o FPS do aparelho. Medir no console antes de aumentar o cenario.
- Sem dependencia de package, io, os, debug, collectgarbage, music ou sfx em tempo de execucao.
- Sem save persistente nem audio nesta versao. O audio da corrida continua sem reproducao confirmada no hardware. Nenhuma descoberta permite prometer som neste prototipo.
- A simulacao usa FPS de ui.stat(7) quando disponivel e dt limitado a 125 ms; sem timer oficial validado, FPS abaixo de oito podem desacelerar o jogo.

Execute na raiz: lua tools/check.lua .
O verificador exercita loader restrito, coordenadas/area dos triangulos, giro, chave, fuga, tiro, dano, reinicio e colisao.
As previas PNG sao reconstruidas a partir das chamadas de desenho reais; nao sao capturas do console.

## Proximo teste no console

Conferir abertura, cores, botoes, legibilidade, FPS parado/andando e contato com inimigo. Depois disso decidir entre manter camera fixa ou adicionar troca de camera por sala, antes de ampliar o mapa.



## Versao 0.2 - personagens articulados e mesas

Personagens com tronco afunilado, cabeca facetada, bracos e pernas independentes (68 triangulos cada). Caminhada sincronizada a distancia realmente percorrida; sem animacao de andar quando bloqueado. Inimigo com postura de bracos para frente e pose de atordoamento. Deformacao dos vertices em buffers reutilizados, sem criar malhas por quadro.

Mesas de madeira com tampo e quatro pes (42 triangulos cada). Faces escondidas dos pes e do tampo removidas. Colisao continua usando o volume inteiro da mesa; ainda nao e possivel passar nem atirar por baixo.

O pico de 156 triangulos foi medido em giro e varredura de posicoes/orientacoes no computador; 92 na versao 0.1. Nao representa FPS do console. Versao 0.1 preservada na tag v0.1-baseline para retorno se necessario.

## Versao 0.3 - piso e cabecas facetadas

O piso agora termina de ser desenhado antes dos objetos e personagens. Isso corrige o piso cobrindo pernas devido a ordenacao por profundidade media, sem subdividir o chao nem adicionar triangulos. Objetos e personagens continuam ordenados juntos para manter oclusao por mesas. Isso nao introduz z-buffer; intersecoes entre outros objetos ainda tem os limites do painter sort.

Cabecas com testa mais larga e queixo estreito. Inimigo com mascara clara, olhos e nariz geometricos, roupa escura e membros animados. Modelo original inspirado na linguagem visual de horror low poly, sem copiar o asset da referencia. Jogador: 76 triangulos; inimigo: 81. A mascara perde detalhe na camera geral pela resolucao e distancia; a previa de detalhe usa uma camera separada de inspecao, nao a camera de jogo.

Pico local amostrado: 171 triangulos (156 na 0.2). FPS do aparelho ainda precisa ser conferido. Testes adicionais verificam piso desenhado antes dos atores e vertices dos pes acima do chao durante um ciclo completo de caminhada.

## Versao 0.4 - qualidade avaliada na camera de jogo

Camera mais proxima, acompanhando a posicao do jogador com orientacao constante. Personagens mais altos, cintura mais estreita, bracos e pernas alongados. Mesmas 309 faces de entrada na cena. Cores do inimigo ajustadas para distinguir roupa e membros do piso. Paleta de cenario mais neutra, ainda em BGR555; a diferenca entre a foto da TV e a previa nao foi diagnosticada nem considerada resolvida.

Previas room e encounter usam exatamente Game.draw e a camera de jogo. Encounter posiciona os atores numa situacao de encontro para avaliar legibilidade. O indicador PC TRI identifica uma reconstrucao local e nao um FPS medido no aparelho. Nao usar o antigo mask-detail como evidencia da qualidade durante o jogo.

A varredura de posicoes e orientacoes verificou silhueta do jogador com pelo menos 45 pixels de altura, coordenadas nativas validas, ausencia de overflow e pico de 180 triangulos. Isso nao mede FPS. No ultimo relato anterior a esta versao, a foto do aparelho mostrava 19 FPS. O enquadramento proximo aumenta a area rasterizada, mesmo sem aumentar a malha; medir novamente no console. Mantidos os controles e o piso separado.

## Versao 0.5 - diagnostico da divergencia no aparelho

O video do console mostrou cores bem mais claras que as reconstrucoes locais; nao foi estabelecida a causa. Nenhuma promessa de equivalencia visual ou correcao de cores nesta versao. Sem aumentar geometria, camera ou complexidade de cena.

X abre/fecha um painel e pausa a simulacao. Sao tres linhas independentes de codificacao: BGR555, RGB555 e RGB565. Cada linha tem cinzas 16/64/128/192, vermelho/verde/azul e branco. Em cada coluna, retangulo acima e os mesmos limites preenchidos por dois triangulos abaixo, usando exatamente o mesmo indice de paleta. Isso ajuda a distinguir problema de formato de cor de uma divergencia entre primitivas nativas. O teste nao seleciona um formato automaticamente; a foto do aparelho e necessaria para concluir. Usa slots 32 a 55 apenas durante o teste; os 32 slots do jogo sao preservados.

A previa anterior foi reconstruida por System.Drawing a partir dos comandos Lua, e nao executada no firmware. Portanto nao valida cores nem rasterizacao do console. O resultado real do video e a referencia para avaliar qualidade.
