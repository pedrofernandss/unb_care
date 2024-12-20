module Exercicios.UnBCare where

import Modelo.ModeloDados

{-
 

██╗░░░██╗███╗░░██╗██████╗░  ░█████╗░░█████╗░██████╗░██████╗
██║░░░██║████╗░██║██╔══██╗  ██╔══██╗██╔══██╗██╔══██╗██╔════╝
██║░░░██║██╔██╗██║██████╦╝  ██║░░╚═╝███████║██████╔╝█████╗░░
██║░░░██║██║╚████║██╔══██╗  ██║░░██╗██╔══██║██╔══██╗██╔══╝░░
╚██████╔╝██║░╚███║██████╦╝  ╚█████╔╝██║░░██║██║░░██║███████╗
░╚═════╝░╚═╝░░╚══╝╚═════╝░  ░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝

O objetivo desse trabalho é fornecer apoio ao gerenciamento de cuidados a serem prestados a um paciente.
O paciente tem um receituario médico, que indica os medicamentos a serem tomados com seus respectivos horários durante um dia.
Esse receituário é organizado em um plano de medicamentos que estabelece, por horário, quais são os remédios a serem
tomados. Cada medicamento tem um nome e uma quantidade de comprimidos que deve ser ministrada.
Um cuidador de plantão é responsável por ministrar os cuidados ao paciente, seja ministrar medicamento, seja comprar medicamento.
Eventualmente, o cuidador precisará comprar medicamentos para cumprir o plano.
O modelo de dados do problema (definições de tipo) está disponível no arquivo Modelo/ModeloDados.hs
Defina funções que simulem o comportamento descrito acima e que estejam de acordo com o referido
modelo de dados.

-}


verificaExistenciaMedicamento :: Medicamento -> EstoqueMedicamentos -> Bool
verificaExistenciaMedicamento medicamento [] = False
verificaExistenciaMedicamento medicamento ((medicamentoDisponivel, quantidadeDisponivel):listTail)
        | medicamento == medicamentoDisponivel = True
        | otherwise = verificaExistenciaMedicamento medicamento listTail
        
atualizaEstoque :: Medicamento -> Quantidade -> EstoqueMedicamentos -> EstoqueMedicamentos
atualizaEstoque medicamento quantidade [] = []
atualizaEstoque medicamento quantidade ((medicamentoDisponivel, quantidadeDisponivel):listTail)
        | medicamento == medicamentoDisponivel = (medicamento, quantidadeDisponivel + quantidade) : listTail
        | otherwise = (medicamentoDisponivel, quantidadeDisponivel) : atualizaEstoque medicamento quantidade listTail

{-

   QUESTÃO 1, VALOR: 1,0 ponto

Defina a função "comprarMedicamento", cujo tipo é dado abaixo e que, a partir de um medicamento, uma quantidade e um
estoque inicial de medicamentos, retorne um novo estoque de medicamentos contendo o medicamento adicionado da referida
quantidade. Se o medicamento já existir na lista de medicamentos, então a sua quantidade deve ser atualizada no novo estoque.
Caso o remédio ainda não exista no estoque, o novo estoque a ser retornado deve ter o remédio e sua quantidade como cabeça.

-}

comprarMedicamento :: Medicamento -> Quantidade -> EstoqueMedicamentos -> EstoqueMedicamentos
comprarMedicamento medicamento quantidade estoque
        | verificaExistenciaMedicamento medicamento estoque = atualizaEstoque medicamento quantidade estoque
        | otherwise = (medicamento, quantidade) : estoque

{-
   QUESTÃO 2, VALOR: 1,0 ponto

Defina a função "tomarMedicamento", cujo tipo é dado abaixo e que, a partir de um medicamento e de um estoque de medicamentos,
retorna um novo estoque de medicamentos, resultante de 1 comprimido do medicamento ser ministrado ao paciente.
Se o medicamento não existir no estoque, Nothing deve ser retornado. Caso contrário, deve se retornar Just v,
onde v é o novo estoque.

-}

tomarMedicamento :: Medicamento -> EstoqueMedicamentos -> Maybe EstoqueMedicamentos
tomarMedicamento medicamento estoque
        | not (verificaExistenciaMedicamento medicamento estoque) = Nothing
        | quantidadeMedicamento == 0 = Nothing
        | otherwise = Just (atualizaEstoque medicamento (-1) estoque)
        where
    quantidadeMedicamento = consultarMedicamento medicamento estoque

{-
   QUESTÃO 3  VALOR: 1,0 ponto

Defina a função "consultarMedicamento", cujo tipo é dado abaixo e que, a partir de um medicamento e de um estoque de
medicamentos, retorne a quantidade desse medicamento no estoque.
Se o medicamento não existir, retorne 0.

-}

consultarMedicamento :: Medicamento -> EstoqueMedicamentos -> Quantidade
consultarMedicamento medicamento [] = 0
consultarMedicamento medicamento ((medicamentoDisponivel, quantidadeDisponivel):listTail)
        | medicamento == medicamentoDisponivel = quantidadeDisponivel
        | otherwise = consultarMedicamento medicamento listTail

{-
   QUESTÃO 4  VALOR: 1,0 ponto

  Defina a função "demandaMedicamentos", cujo tipo é dado abaixo e que computa a demanda de todos os medicamentos
  por um dia a partir do receituario. O retorno é do tipo EstoqueMedicamentos e deve ser ordenado lexicograficamente
  pelo nome do medicamento.

  Dica: Observe que o receituario lista cada remédio e os horários em que ele deve ser tomado no dia.
  Assim, a demanda de cada remédio já está latente no receituario, bastando contar a quantidade de vezes que cada remédio
  é tomado.

-}

calcularDemanda :: Receituario -> EstoqueMedicamentos
calcularDemanda [] = []
calcularDemanda ((medicamento, horarios):listTail) =
    (medicamento, length horarios) : calcularDemanda listTail

ordenaAlfabeticamente :: EstoqueMedicamentos -> EstoqueMedicamentos
ordenaAlfabeticamente [] = []
ordenaAlfabeticamente (prescricaoAtual:restoLista) =
    inserirMedicamento (ordenaAlfabeticamente restoLista) prescricaoAtual
  where
    inserirMedicamento :: EstoqueMedicamentos -> (Medicamento, Quantidade) -> EstoqueMedicamentos
    inserirMedicamento [] prescricaoAtual = [prescricaoAtual]
    inserirMedicamento (primeiraPrescricaoLista:restoLista) prescricaoAtual
        | fst prescricaoAtual <= fst primeiraPrescricaoLista = prescricaoAtual : (primeiraPrescricaoLista:restoLista)
        | otherwise = primeiraPrescricaoLista : inserirMedicamento restoLista prescricaoAtual

demandaMedicamentos :: Receituario -> EstoqueMedicamentos
demandaMedicamentos receituario = ordenaAlfabeticamente (calcularDemanda receituario)


{-
   QUESTÃO 5  VALOR: 1,0 ponto, sendo 0,5 para cada função.

 Um receituário é válido se, e somente se, todo os medicamentos são distintos e estão ordenados lexicograficamente e,
 para cada medicamento, seus horários também estão ordenados e são distintos.

 Inversamente, um plano de medicamentos é válido se, e somente se, todos seus horários também estão ordenados e são distintos,
 e para cada horário, os medicamentos são distintos e são ordenados lexicograficamente.

 Defina as funções "receituarioValido" e "planoValido" que verifiquem as propriedades acima e cujos tipos são dados abaixo:

 -}

verificaUnicidadeOrdem :: Ord a => [a] -> Bool
verificaUnicidadeOrdem [] = True
verificaUnicidadeOrdem [_] = True
verificaUnicidadeOrdem (primeiroElementoLista:segundoElementoLista:restoLista) 
        | primeiroElementoLista < segundoElementoLista = verificaUnicidadeOrdem (segundoElementoLista:restoLista)
        | otherwise = False  


receituarioValido :: Receituario -> Bool
receituarioValido receituario = medicamentosOrdenadosEValidos && horariosOrdenadosEValidos
        where
                medicamentosOrdenadosEValidos = verificaUnicidadeOrdem (map fst receituario)
                horariosOrdenadosEValidos = all verificaUnicidadeOrdem (map snd receituario)


planoValido :: PlanoMedicamento -> Bool
planoValido planoMedicamento = horariosOrdenadosEValidos && medicamentosOrdenadosEValidos
        where 
                horariosOrdenadosEValidos = verificaUnicidadeOrdem (map fst planoMedicamento)
                medicamentosOrdenadosEValidos = all verificaUnicidadeOrdem (map snd planoMedicamento)

{-

   QUESTÃO 6  VALOR: 1,0 ponto,

 Um plantão é válido se, e somente se, todas as seguintes condições são satisfeitas:

 1. Os horários da lista são distintos e estão em ordem crescente;
 2. Não há, em um mesmo horário, ocorrência de compra e medicagem de um mesmo medicamento (e.g. `[Comprar m1, Medicar m1 x]`);
 3. Para cada horário, as ocorrências de Medicar estão ordenadas lexicograficamente.

 Defina a função "plantaoValido" que verifica as propriedades acima e cujo tipo é dado abaixo:

 -}


listaCompras :: [Cuidado] -> [Medicamento]
listaCompras [] = []
listaCompras (Comprar medicamento _ : restoLista) = medicamento : listaCompras restoLista
listaCompras (_ : restoLista) = listaCompras restoLista

listaMedicar :: [Cuidado] -> [Medicamento]
listaMedicar [] = []
listaMedicar (Medicar medicamento : restoLista) = medicamento : listaMedicar restoLista
listaMedicar (_ : restoLista) = listaMedicar restoLista

verificaConflitoComprarMedicar :: [Cuidado] -> Bool
verificaConflitoComprarMedicar listaCuidados = existeConflito (listaCompras listaCuidados) (listaMedicar listaCuidados)
        where
            existeConflito [] _ = False
            existeConflito (atual:restoLista) listaMedicamentos
                | pertence atual listaMedicamentos = True
                | otherwise = existeConflito restoLista listaMedicamentos
            pertence _ [] = False
            pertence elemento (atual:restoLista)
                | elemento == atual = True
                | otherwise = pertence elemento restoLista

verificaOrdenacaoMedicar :: [Cuidado] -> Bool
verificaOrdenacaoMedicar listaCuidados = verificaUnicidadeOrdem (listaMedicar listaCuidados)

plantaoValido :: Plantao -> Bool
plantaoValido [] = True
plantaoValido ((horario, cuidados) : restoLista) = verificaUnicidadeOrdem (map fst ((horario, cuidados) : restoLista)) && not (verificaConflitoComprarMedicar cuidados) && verificaOrdenacaoMedicar cuidados && plantaoValido restoLista


{-
   QUESTÃO 7  VALOR: 1,0 ponto

  Defina a função "geraPlanoReceituario", cujo tipo é dado abaixo e que, a partir de um receituario válido,
  retorne um plano de medicamento válido.

  Dica: enquanto o receituário lista os horários que cada remédio deve ser tomado, o plano de medicamentos  é uma
  disposição ordenada por horário de todos os remédios que devem ser tomados pelo paciente em um certo horário.

-}

geraPlanoReceituario :: Receituario -> PlanoMedicamento
geraPlanoReceituario [] = []
geraPlanoReceituario ((medicamento, horarios):restoReceituario) =
    ordenaPlano (adicionaMedicamentos horarios medicamento (geraPlanoReceituario restoReceituario))
  where
    adicionaMedicamentos [] _ plano = plano
    adicionaMedicamentos (horario:restoHorarios) medicamento [] =
        (horario, [medicamento]) : adicionaMedicamentos restoHorarios medicamento []
    adicionaMedicamentos (horario:restoHorarios) medicamento ((h, meds):restoPlano)
        | horario == h = (h, medicamento : meds) : adicionaMedicamentos restoHorarios medicamento restoPlano
        | otherwise = (h, meds) : adicionaMedicamentos (horario : restoHorarios) medicamento restoPlano

    ordenaPlano [] = []
    ordenaPlano (x:xs) = insereOrdenado x (ordenaPlano xs)

    insereOrdenado elem [] = [elem]
    insereOrdenado (horario, meds) ((h, medsList):restoOrdenado)
        | horario <= h = (horario, meds) : (h, medsList) : restoOrdenado
        | otherwise = (h, medsList) : insereOrdenado (horario, meds) restoOrdenado



{- QUESTÃO 8  VALOR: 1,0 ponto

 Defina a função "geraReceituarioPlano", cujo tipo é dado abaixo e que retorna um receituário válido a partir de um
 plano de medicamentos válido.
 Dica: Existe alguma relação de simetria entre o receituário e o plano de medicamentos? Caso exista, essa simetria permite
 compararmos a função geraReceituarioPlano com a função geraPlanoReceituario ? Em outras palavras, podemos definir
 geraReceituarioPlano com base em geraPlanoReceituario ?

-}

geraReceituarioPlano :: PlanoMedicamento -> Receituario
geraReceituarioPlano [] = []
geraReceituarioPlano plano =
    [(medicamento, ordenar [horario | (horario, medicamentos) <- plano, medicamento `elem` medicamentos])
    | medicamento <- ordenar (removerDuplicatas (extrairMedicamentos plano))]
  where
    extrairMedicamentos [] = []
    extrairMedicamentos ((_, medicamentos) : restoLista) = medicamentos ++ extrairMedicamentos restoLista

    removerDuplicatas [] = []
    removerDuplicatas (elementoAtual:proximosElementos)
        | elementoAtual `elem` proximosElementos = removerDuplicatas proximosElementos
        | otherwise = elementoAtual : removerDuplicatas proximosElementos

    ordenar [] = []
    ordenar (elementoAtual:proximosElementos) = ordenar [y | y <- proximosElementos, y <= elementoAtual] ++ [elementoAtual] ++ ordenar [y | y <- proximosElementos, y > elementoAtual]



{-  QUESTÃO 9 VALOR: 1,0 ponto

Defina a função "executaPlantao", cujo tipo é dado abaixo e que executa um plantão válido a partir de um estoque de medicamentos,
resultando em novo estoque. A execução consiste em desempenhar, sequencialmente, todos os cuidados para cada horário do plantão.
Caso o estoque acabe antes de terminar a execução do plantão, o resultado da função deve ser Nothing. Caso contrário, o resultado
deve ser Just v, onde v é o valor final do estoque de medicamentos

-}

executaPlantao :: Plantao -> EstoqueMedicamentos -> Maybe EstoqueMedicamentos
executaPlantao [] estoque = Just estoque
executaPlantao ((_, cuidados) : restoPlantao) estoque =
    executaCuidados cuidados estoque >>= \estoqueAtualizado ->
        executaPlantao restoPlantao estoqueAtualizado
  where
    executaCuidados [] estoqueAtual = Just estoqueAtual
    executaCuidados (Comprar medicamento quantidade : restoCuidados) estoqueAtual =
        executaCuidados restoCuidados (atualizarEstoqueAdicionar medicamento quantidade estoqueAtual)
    executaCuidados (Medicar medicamento : restoCuidados) estoqueAtual =
        case atualizarEstoqueRemover medicamento estoqueAtual of
            Nothing -> Nothing
            Just novoEstoque -> executaCuidados restoCuidados novoEstoque

    atualizarEstoqueAdicionar medicamento quantidade [] = [(medicamento, quantidade)]
    atualizarEstoqueAdicionar medicamento quantidade ((m, q) : estoqueRestante)
        | m == medicamento = (m, q + quantidade) : estoqueRestante
        | otherwise = (m, q) : atualizarEstoqueAdicionar medicamento quantidade estoqueRestante

    atualizarEstoqueRemover _ [] = Nothing
    atualizarEstoqueRemover medicamento ((m, q) : estoqueRestante)
        | m == medicamento && q > 0 = Just ((m, q - 1) : estoqueRestante)
        | m == medicamento = Nothing
        | otherwise = case atualizarEstoqueRemover medicamento estoqueRestante of
            Nothing -> Nothing
            Just novoEstoque -> Just ((m, q) : novoEstoque)


{-
QUESTÃO 10 VALOR: 1,0 ponto

Defina uma função "satisfaz", cujo tipo é dado abaixo e que verifica se um plantão válido satisfaz um plano
de medicamento válido para um certo estoque, ou seja, a função "satisfaz" deve verificar se a execução do plantão
implica terminar com estoque diferente de Nothing e administrar os medicamentos prescritos no plano.
Dica: fazer correspondencia entre os remédios previstos no plano e os ministrados pela execução do plantão.
Note que alguns cuidados podem ser comprar medicamento e que eles podem ocorrer sozinhos em certo horário ou
juntamente com ministrar medicamento.

-}

satisfaz :: Plantao -> PlanoMedicamento -> EstoqueMedicamentos -> Bool
satisfaz plantao plano estoque = verificaPlano plantao plano estoque

verificaPlano :: Plantao -> PlanoMedicamento -> EstoqueMedicamentos -> Bool
verificaPlano [] [] estoque = all (\(_, qtd) -> qtd >= 0) estoque
verificaPlano ((horarioP, cuidados):restoPlantao) ((horarioM, meds):restoPlano) estoque
  | horarioP == horarioM = verificaPlano restoPlantao restoPlano (executaCuidados cuidados estoque)
  | otherwise = False

executaCuidados :: [Cuidado] -> EstoqueMedicamentos -> EstoqueMedicamentos
executaCuidados [] estoque = estoque
executaCuidados ((Comprar med qtd):restoCuidados) estoque = executaCuidados restoCuidados (atualizaEstoque med qtd estoque)
executaCuidados ((Medicar med):restoCuidados) estoque = executaCuidados restoCuidados (atualizaEstoque med (-1) estoque)



{-

QUESTÃO 11 VALOR: 1,0 ponto

 Defina a função "plantaoCorreto", cujo tipo é dado abaixo e que gera um plantão válido que satisfaz um plano de
 medicamentos válido e um estoque de medicamentos.
 Dica: a execução do plantão deve atender ao plano de medicamentos e ao estoque.

-}

plantaoCorreto :: PlanoMedicamento -> EstoqueMedicamentos -> Plantao
plantaoCorreto plano estoque = reverse (processaPlano plano estoque [])

processaPlano :: PlanoMedicamento -> EstoqueMedicamentos -> Plantao -> Plantao
processaPlano [] _ plantao = plantao
processaPlano ((horario, meds):restoPlano) estoque plantao =
  let (cuidados, novoEstoque) = processaMedicamentos meds estoque
      novoPlantao = (horario, cuidados) : plantao
  in processaPlano restoPlano novoEstoque novoPlantao

processaMedicamentos :: [Medicamento] -> EstoqueMedicamentos -> ([Cuidado], EstoqueMedicamentos)
processaMedicamentos meds estoque = foldl processaMedicamento ([], estoque) meds

processaMedicamento :: ([Cuidado], EstoqueMedicamentos) -> Medicamento -> ([Cuidado], EstoqueMedicamentos)
processaMedicamento (cuidados, estoque) med =
  case lookup med estoque of
    Just qtd | qtd > 0 ->
      let novoEstoque = atualizaEstoque med (-1) estoque
      in (cuidados ++ [Medicar med], novoEstoque)
    _ ->
      let novoEstoque = atualizaEstoque med 1 estoque
      in (cuidados ++ [Comprar med 1, Medicar med], novoEstoque)
