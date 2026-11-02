# Assets usados na cena 0.6

Todos foram baixados das paginas dos autores em 2 de novembro de 2026. As malhas de runtime em asset_meshes.lua sao conversoes reais desses arquivos, nao modelos gerados para parecerem com as imagens.

| Objeto | Autor / pagina | Arquivo de origem | Triangulos de origem / runtime |
|---|---|---|---|
| Jogador | Comp-3 Interactive: https://comp3interactive.itch.io/low-poly-human-mesh | Humanoid.fbx, HumanoidBase_NotOverlapping | 402 / 180 |
| Inimigo | Puck: https://puszke.itch.io/psx-low-poly-skeleton | Skeleton/skeleton.fbx | 1762 / 183 |
| Escrivaninha | mastjie (samusaa): https://mastjie.itch.io/low-poly-household-goods | gltf/desk_01.glb | 161 / 44 |
| Cadeira | mesmo pack de mastjie | gltf/chair_01.glb | 330 / 26 |
| Armario | mesmo pack de mastjie | gltf/cupboard_01.glb | 150 / 20 |

## Licencas e creditos

Comp-3 declara CC0 na pagina. Credito adicional a Emerald Eel, autor da base original, que solicita mencao e link: https://emerald-eel.itch.io/human-size-reference-model . Mantemos os dois creditos, sem apresentar o modelo como autoria nossa.

Puck declara CC0 na pagina do esqueleto. O arquivo license.txt do pack mastjie declara CC0 1.0 Universal: https://creativecommons.org/publicdomain/zero/1.0/ . Creditos ao autor samusaa/mastjie e sua pagina, embora CC0 nao exija atribuicao.

O pack Lowbit Lab foi inspecionado localmente mas NAO utilizado nesta cena, devido a restricao sobre redistribuicao dos modelos brutos no repositorio publico. Nenhum arquivo desse pack foi incluido no jogo ou neste GitHub.

## Transformacoes

FBX extraidos offline com ufbx; GLB lidos offline em Python. Normalizacao dos personagens para 1.85 unidades de altura, alinhamento dos pes ao piso, eixo vertical ajustado e bracos da pose base abaixados. Simplificacao com meshoptimizer 1.3.0 (MIT), preservando vertices de origem selecionados por erro geometrico; nao houve descarte aleatorio de faces. Cabecas, torax e membros pertencem aos modelos de origem.

Cores dos personagens atribuidas por regiao anatomica; cores dos moveis amostradas de materiais/texturas e aproximadas a paleta do jogo. Luz por face calculada offline. Texturas, rigging e animacoes originais nao sao carregados pelo firmware.

A caminhada usa os vertices das malhas importadas com agrupamento simplificado de bracos/pernas; nao e uma reproducao das animacoes dos packs nem um sistema completo de cotovelos/joelhos. Buffers de vertices e trigonometria sao reutilizados. Pose elevada quando necessario para evitar penetracao dos pes.

Os arquivos brutos ficam fora do pacote executavel. asset_meshes.lua tem aproximadamente 12 KB em disco; tamanho em RAM e desempenho no console nao podem ser inferidos desse tamanho. O runtime nao depende de Blender, Python, ufbx, meshoptimizer ou carregadores FBX/GLB.
