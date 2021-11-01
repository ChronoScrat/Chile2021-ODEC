# Projeto Eleições: Chile 2021

Olá,

Bem vinde! Esse repositório contém o código e os arquivos utilizados para gerar a média ajustada de intenção de votos dos candidatos à eleição presidencial do Chile de 2021 presente no ODEC-USP. O artigo original pode ser encontrado [aqui](https://example.com).

Esse modelo de média ajustada nada mais é do que uma super simplificação do modelo de intenção de voto usado pelo [FiveThirtyEight](https://fivethirtyeight.com/) para as eleições dos Estados Unidos. O procedimento e as suposições utilizadas estão detalhadas mais abaixo.

Caso encontre algum erro, queira atualizar as pesquisas ou melhorar o código, PR são muito bem-vindos!

Obrigado!

---

## As Pesquisas

Primeiramente, é importante destacar o universo das pesquisas utilizadas nesse modelo. Por uma questão de praticidade, somente foram utilizadas as pesquisas eleitorais realizadas após a homologação definitiva de todos os candidatos pelo SERVEL.

Na prática, isso significa dizer que somente foram incluídas pesquisas realizadas após 26 de agosto de 2021. Embora pesquisas anteriores pudessem ser utilizadas, elas apenas trariam complexidade ao modelo.

## O Modelo

Para o modelo, primeiramente atribuímos a cada pesquisa um peso de acordo com o tamanho da amostra dela. Com isso, penalizamos as pesquisas que possuem amostras muito pequenas e, portanto, resultados menos fidedignos à realidade.

O esquema de pesos é o seguinte:

| Amostra | Peso |
|---------|------|
| 1500+ | 1 |
| Entre 1000 e 1500 | 0.9 |
| Entre 750 e 1000 | 0.7 |
| Entre 500 e 750 | 0.5 |
| Entre 300 e 500 | 0.1 |
| Entre 0 e 300 | 0 |

Na prática, essa associação de pesos penaliza as pesquisas muito pequenas, enquanto privilegia as que possuem grandes amostras. A maior parte das pesquisas dentro da faixa de 1000 e 1500, salvas algumas semanais.

Em seguida, modificamos esse peso de acordo com a proximidade da eleição. Dado que pesquisas mais próximas do período eleitoral tendem a refletir melhor a opinião do eleitor, pesquisas realizadas até 30 dias antes da eleição têm o seu peso aumentado da seguinte forma:

$$Peso \times (2 - \frac{\text{Data da Eleição} - \text{Data da Pesquisa}}{30}) $$

Isso significa que pesquisas realizadas 30 dias antes da eleição terão o peso multiplicado por 1, enquanto que pesquisas realizadas **no dia** da eleição (boca de urna) terão o peso dobrado.

Por fim, o peso é ajustado diariamente para garantir que quanto mais antiga for a pesquisa em relação à data atual, menor será o peso efetivo dela no modelo. Isso ocorre porque a intenção de voto do eleitor tende a se modificar ao longo do tempo, e portanto resultados de pesquisas muito antigos - se continuassem com o mesmo peso - poderiam enviesar negativamente o modelo.

Esse ajuste é feito da seguinte forma:

1. Se a pesquisa foi realizada há no máximo sete dias, o peso ajustado dela será igual ao peso original.
2. Se a pesquisa foi realizada entre 7 e 45 dias, o peso dela será ajustado de acordo com a fórmula:
$$Peso \times (1 - \frac{\text{Data atual} - \text{Data da Pesquisa}}{45})$$

Assim, a pesquisa deixa de influenciar completamente o modelo no momento em que 45 dias são decorridos de sua publicação.

O passo do ajuste diário é repetido para cada dia desde 26/08/2021, sendo aplicado somente as pesquisas que forma publicadas até essa data (pesquisas que não foram são desconsideradas).