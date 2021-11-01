################################################################################
###                             PROJETO CHILE 2021                           ###
###            MÉDIA AJUSTADA DA INTENÇÃO DE VOTO - PRIMEIRO TURNO           ###
################################################################################

## @author Nathanael Rolim <nathanael.rolim@usp.br>

################################################################################



# Importa as Bibliotecas de Código

library(tidyverse)
library(dplyr)
library(jsonlite)
library(lubridate)



# Define algumas variáveis que serão importantes

DataEleicao = dmy("21/11/2021") # Dia da Eleição
DiasPesquisa = data.frame(dias = dmy("26/08/2021") + 0:90)



# Importa a base de dados

pesquisas <- read.csv(
  file = "./data/Primeiro Turno.csv",
  header = TRUE,
  sep=";"
)

# Por pardão, o R costuma enfrentar problemas em ler alguns dados como data.
# Aqui, garantiremos que a coluna "DataPub" será lida como data de fato.

pesquisas <- pesquisas %>%
  mutate(
    DataPub = ymd(DataPub)
  )

# Vamos deletar a coluna de links, já que não precisaremos dela

pesquisas <- pesquisas %>%
  select(
    -Link
  )

################################################################################

# Devemos, agora, associar um peso para cada pesquisa que irá variar de acordo
# com o tamanho da amostra dela.

pesquisas <- pesquisas %>%
  mutate(
    Peso = ifelse(Amostra >= 1500, 1,
                  ifelse(Amostra >= 1000 & Amostra < 1500, 0.9,
                         ifelse(Amostra >= 750 & Amostra < 1000, 0.7,
                                ifelse(Amostra >= 500 & Amostra < 750, 0.5,
                                       ifelse(Amostra >= 300 & Amostra < 500, 0.1, 0
                                              )
                                       )
                                )
                         )
                  )
  )


# Agora realizaremos o ajuste do peso de acordo com a proximidade da data da
# eleição. Com isso, captaremos melhor o interesse do eleitor. Isso posto, temos
# um intervalo muito pequeno, então devemos levar esse ajuste com cautela

pesquisas <- pesquisas %>%
  mutate(
    Peso = ifelse(DataEleicao - DataPub <= 30, 
                  Peso * (2 - ((DataEleicao - DataPub)/30)),
                  Peso
    )
  )


################################################################################

# Tendo feito os ajustes necessários, agora rodaremos o ajuste do peso para cada
# um dos dias presentes em "DiasPesquisa"

# Para isso, primeiro nos asseguraremos que o local onde salvaremos o arquivo
# existe

if(!file.exists("./output/diaria1T.csv")){
  temp <- read.table(header = TRUE,
                     stringsAsFactors = FALSE,
                     colClasses = c("character","Date","numeric"),
                     text = "Candidato DataP Porcentagem"
                     )
  
  write.table(temp,
              file = "./output/diaria1T.csv",
              sep = ";",
              col.names = TRUE,
              row.names = FALSE
  )
  
  rm(temp)
  
}

# Cria um DF igual ao "pesquisas", no qual as operações serão realizadas. Defi-
# niremos também uma variável contendo o dia máximo das pesquisas, que será uti-
# lizado na função a seguir.

TabelaTemp <- pesquisas
maximo <- today()

# Iniciaremos agora o ajuste diário de pesos

for(i in 1:length(DiasPesquisa$dias)){
  
  BaseData <- DiasPesquisa$dias[i]
  
  TabelaTemp <- TabelaTemp %>%
    mutate(PesoAjustado = 
             ifelse(BaseData < DataPub | BaseData > maximo, 0,
                    ifelse(BaseData - DataPub <= 7, Peso,
                           ifelse(BaseData - DataPub > 7 & BaseData - DataPub <= 45,
                                  Peso * (1 - ((BaseData - DataPub)/45)),0
                                  )
                           )
                    )
             )
  
  DFTemp <- TabelaTemp %>%
    group_by(Candidatura) %>%
    summarise(DataT = as.POSIXlt(BaseData, tz="BRT"), Perc = round(weighted.mean(Percentual,PesoAjustado), digits = 2)) %>%
    ungroup()
  
  write.table(DFTemp,
              file = "./output/diaria1T.csv",
              append = TRUE,
              sep = ";",
              col.names = FALSE,
              row.names = FALSE,
              na = "0"
              )
  
  
}
