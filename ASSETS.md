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

## Comparacao 0.7

asset_meshes_full.lua preserva todas as faces de origem: humano 402, esqueleto 1762, escrivaninha 161, cadeira 330, armario 150. As contagens reduzidas da tabela acima continuam disponiveis em asset_meshes.lua no modo LEVE (L). O modo ORIGINAL e o padrao e usa a pose de origem sem a deformacao de membros da 0.6. O humano e cinza neutro; nao tem a camisa azul inventada da adaptacao anterior. Cores do esqueleto amostradas nos UVs do base.png original; cores dos moveis amostradas no centro UV de cada triangulo, sem misturar amostras dos vertices nas bordas do atlas. A paleta foi ampliada a 48 entradas para evitar substituir tons de osso por verde.

Texturas nao sao aplicadas por pixel: cada triangulo recebe uma cor. Portanto a geometria e integral, mas o visual nao equivale a um renderizador com texturas e iluminacao original.

Os sete arquivos .fur e o gerador tools/build-audio.cjs sao composicoes/efeitos procedurais originais deste projeto, derivados do gerador proprio da corrida; nao sao musicas ou samples copiados dos packs nem de jogos oficiais.

## Beco pre-renderizado 0.8

Fonte: PSX style urban stacked pack, valsekamerplant: https://valsekamerplant.itch.io/psx-style-urban-stacked-pack . Pack principal gratuito, licenca CC0 declarada pelo autor; texturas CC0 ou fotografias proprias, sem IA generativa. Download do pack gratuito em 2 de novembro de 2026, sem comprar nem usar os arquivos-fonte pagos.

Usados: road_4_straight_no_sides.glb, brick_wall_window_1.glb, brick_wall_window_2.glb, brick_wall.glb, brick_wall_metal_door.glb, dumpster_diagonal_closed.glb, street_light.glb e metalfence_both_sides_topbar.glb. As malhas e texturas foram importadas no Blender 4.2.0; cena montada e iluminada offline no Cycles. Conversao de GLTF para a cena, normalizacao de escala/origem, posicionamento, render de camera fixa, reducao a BGR555 e paleta compartilhada. Os moveis mastjie da versao anterior nao sao desenhados no beco.

Arquivos de runtime: backgrounds/alley.png, backgrounds/dumpster.png e backgrounds/swatches.png. A mascara usa os mesmos pixels do render de fundo sob uma silhueta renderizada separadamente, evitando mudar a iluminacao da cacamba ao reaplica-la.

Reproducao: com Blender 4.2/bpy e o pack extraido, defina URBAN_ASSETS para o diretorio URBAN e execute tools/render-alley.py. Os renders, a cena .blend com texturas empacotadas e os dados de camera ficam em .build/alley. tools/prepare-background.py usa Pillow e a paleta base salva em .build/alley/source-palette.txt para preparar os PNGs, background_layout.lua e background_palette.lua. A paleta base pode ser exportada com Lua usando C.source de colors.lua. tools/build-prerender.py gera os bitmaps e o manifesto nativo. Blender e as ferramentas offline nao sao carregados pelo Lupi.
