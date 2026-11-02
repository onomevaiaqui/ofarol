# Ultima Saida - survival horror 3D para Lupi

Prototipo 0.2 independente do jogo de corrida. Uma sala de deposito, um personagem, um inimigo, uma chave e uma porta de fuga. Camera fixa obliqua; malhas XYZ projetadas em perspectiva e rasterizadas com ui.trisfill. Sem raycasting 2,5D, texturas ou sombras dinamicas.

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
- Cena: 288 triangulos de entrada (incluindo chave e atores); pico amostrado: 156 triangulos nativos visiveis. O numero exibido e calculado por quadro.
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
