# Casa Sombria — A Última Entrega

Às 23h47, um entregador de pizza chega a uma rua sem saída. A encomenda é para a casa 37, ao lado do parquinho.

## Como jogar

- Direcional ou WASD para andar.
- Botão de ação oeste ou M para interagir.
- Botão de ação norte ou L para recomeçar depois do prólogo.

Siga pela rua até o parquinho. A casa fica à direita. Aproxime-se da campainha para interagir.

## Como executar

Abra o arquivo casa-sombria.lupi no Lupinho. Para executar o código extraído, também é possível passar a pasta do jogo como argumento ao simulador.

O cartucho contém quatro fundos rasterizados de 480 × 270 em formato indexado, com uma paleta global BGR555 de 16 cores. Para gerar novamente os fundos e o manifesto, execute `node render.cjs`.

A API de referência é a do [simulador Lupinho](https://github.com/lupi-org-br/lupinho). O percurso foi validado em Lua com entradas simuladas. O desempenho e a compatibilidade do cartucho no aparelho físico ainda precisam de teste.
