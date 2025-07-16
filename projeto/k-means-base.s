#
# IAC 2023/2024 k-means
# 
# Grupo: 16
# Campus: Taguspark
#
# Autores:
# 109369, Salvador Pereira
# 109474, Daniel Borges
# 110181, Duarte Cruz
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7, 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters:    .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
previous_centroids: .word 0,0, 0,0, 0,0


#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    #jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    

### cleanScreen
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    add t0, x0, x0 #x = 0
    add t1, x0, x0 #y = 0
    addi t2, x0, 31 #limit = 31
    li a2, white #load color
    addi sp, sp, -4 #reservar espaco na pilha
    sw ra, 0(sp) #guardar endereco de retorno
    cleanScreenLoop:
        add a0, t0, x0 #por o x no argumento
        add a1, t1, x0 #por o y no argumento
        jal printPoint #pintar ponto
        beq t0, t2 cleanScreenNextY #se o x chegou ao limite
        addi t0, t0, 1 #x++
        j cleanScreenLoop #invocacao recursiva
    cleanScreenNextY:
        beq t1, t2 endCleanScreen #se o y chegou ao limite
        add t0, x0, x0 #x = 0
        addi t1, t1, 1 #y++
        j cleanScreenLoop #invocacao recursiva
    endCleanScreen:
        lw ra, 0(sp) #repor endereco de retorno
        addi sp, sp, 4 #libertar espaco na pilha
        jr ra #retorna ao ponto de invocacao

    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    la t0 points #load do vetor de pontos
    lw t1 n_points #load do numero de pontos restantes
    la t2 clusters #load do vetor do cluster de cada ponto
    la t3, colors #load cores
    addi sp, sp, -4 #reservar espaco na pilha
    sw ra, 0(sp) #guardar endereco de retorno
    printClustersLoop:
        beq x0, t1, printClustersEnd #terminar se chegar ao fim do vetor
        lw a0, 0(t0) #x toma o valor do primeiro elemento
        lw a1, 4(t0) #y toma o valor do segundo elemento
        lw a2, 0(t2) #load indice do cluster do ponto
        slli a2, a2, 2 #multiplicar por 4
        add a2, t3, a2 #obter endereco de cor pretendida
        lw a2, 0(a2) #obter cor pretendida
        jal printPoint #pintar ponto
        addi t0, t0, 8 #proximo ponto
        addi t2, t2, 4 #proximo cluster
        addi t1, t1, -1 #menos 1 ponto por ver
        j printClustersLoop #invocacao recursiva
    printClustersEnd:
        lw ra, 0(sp) #repor endereco de retorno
        addi sp, sp, 4 #libertar espaco na pilha
        jr ra #retorna ao ponto de invocacao


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    la t0 centroids #load do vetor de centroides
    lw t1 k #load do numero de centroides restantes
    li a2, black #load color
    addi sp, sp, -4 #reservar espaco na pilha
    sw ra, 0(sp) #guardar endereco de retorno
    printCentroidsLoop:
        beq x0, t1, printCentroidsEnd #terminar se chegar ao fim do vetor
        lw a0, 0(t0) #x toma o valor do primeiro elemento
        lw a1, 4(t0) #y toma o valor do segundo elemento
        jal printPoint #pintar ponto
        addi t0, t0, 8 #proximo ponto
        addi t1, t1, -1 #menos 1 ponto por ver
        j printCentroidsLoop #invocacao recursiva
    printCentroidsEnd:
        lw ra, 0(sp) #repor endereco de retorno
        addi sp, sp, 4 #libertar espaco na pilha
        jr ra #retorna ao ponto de invocacao

    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    la a0, points
    lw a1, n_points
    la a2,centroids  #load do vetor de centroids
    la a3,clusters
    li t4,0    #vai corresponder ao numero de pontos no cluster0
    li t5,0    #vai corresponder ao numero de pontos no cluster1
    li t6,0    #vai corresponder ao numero de pontos no cluster2
    calculateCentroidsLoop:
        beq a1,x0,calculateCentroidsEnd    #caso ja tenhamos verificado todos os pontos, passa para o End
        lw t1,0(a0)      #t1 corresponde ao x do ponto
        lw t2,4(a0)      #t2 corresponde ao y do ponto
        lw t0,0(a3)      #t0 corresponde ao indice do cluster do ponto que estamos a ver
        slli t3, t0, 3   #t3 corresponde a posicao em bits do x do centroide k
        add a2,t3,a2     #vai para a posicao em bits do x do centroide k no vetor centroids
        lw s1,0(a2)      #guarda a soma dos x's ate agora em t3
        add s1,s1,t1     #adiciona o x do novo ponto ao t3
        sw s1,0(a2)      #guarda o valor atualizado no x do centroide 
        lw s1,4(a2)      #guarda a soma dos y's ate agora em t3
        add s1,s1,t2     #adiciona o y do novo ponto ao t3
        sw s1,4(a2)      #guarda o valor atualizado no y do centroide
        sub a2,a2,t3
        addi a0,a0,8     #passar para o proximo ponto no vetor points
        addi a1,a1,-1    #retirar 1 do numero de pontos por ver
        addi a3,a3,4     #passa para o proximo ponto no vetor clusters
        beq t0,x0,calculateCentroidsAdd0   #caso seja o cluster0, vamos para o loop add0
        addi t3, x0, 1   #t3 = 1 para compararmos com t0
        beq t0,t3,calculateCentroidsAdd1   #caso seja o cluster1, vamos para o loop add1
        addi t3, t3, 1   #t3 = 2 para compararmos com t0
        beq t0,t3,calculateCentroidsAdd2   #caso seja o cluster2, vamos para o loop add2
        calculateCentroidsAdd0:
            addi t4,t4,1 #adicionamos 1 ao numero de pontos pertencentes ao cluster0
            j calculateCentroidsLoop #nova iteracao
        calculateCentroidsAdd1:
            addi t5,t5,1 #adicionamos 1 ao numero de pontos pertencentes ao cluster1
            j calculateCentroidsLoop #nova iteracao
        calculateCentroidsAdd2:
            addi t6,t6,1 #adicionamos 1 ao numero de pontos pertencentes ao cluster2
            j calculateCentroidsLoop #nova iteracao
    calculateCentroidsEnd:
        lw t1,0(a2)     #t1=soma total dos x's dos pontos pertencentes ao cluster0
        div t1,t1,t4    #dividimos a soma dos x dos pontos do cluster0 pelo numero de pontos pertencentes a esse cluster
        sw t1,0(a2)     #guardarmos o novo valor no x do cluster0
        lw t1,4(a2)     #t1=soma total dos y's dos pontos pertencentes ao cluster0
        div t1,t1,t4    #dividimos a soma dos y dos pontos do cluster0 pelo numero de pontos pertencentes a esse cluster
        sw t1,4(a2)     #guardarmos o novo valor no y do cluster0
        
        lw t1,8(a2)     #t1=soma total dos x's dos pontos pertencentes ao cluster1
        div t1,t1,t5    #dividimos a soma dos x dos pontos do cluster1 pelo numero de pontos pertencentes a esse cluster
        sw t1,8(a2)     #guardarmos o novo valor no x do cluster1
        lw t1,12(a2)    #t1=soma total dos y's dos pontos pertencentes ao cluster1
        div t1,t1,t5    #dividimos a soma dos y dos pontos do cluster1 pelo numero de pontos pertencentes a esse cluster
        sw t1,12(a2)    #guardarmos o novo valor no y do cluster1
        
        lw t1,16(a2)    #t1=soma total dos x's dos pontos pertencentes ao cluster2
        div t1,t1,t6    #dividimos a soma dos x dos pontos do cluster2 pelo numero de pontos pertencentes a esse cluster
        sw t1,16(a2)    #guardarmos o novo valor no x do cluster2
        lw t1,20(a2)    #t1=soma total dos y's dos pontos pertencentes ao cluster2
        div t1,t1,t6    #dividimos a soma dos y dos pontos do cluster2 pelo numero de pontos pertencentes a esse cluster
        sw t1,20(a2)    #guardarmos o novo valor no y do cluster2
        jr ra


### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    addi sp, sp, -4 #reservar espaco na pilha
    sw ra, 0(sp) #guardar endereco de retorno
    #1. Coloca k=1
    la t0, k
    addi t1, x0, 1
    sw t1, 0(t0)

    #2. cleanScreen
    jal cleanScreen

    #3. printClusters
    jal printClusters

    #4. calculateCentroids
    jal calculateCentroids

    #5. printCentroids
    jal printCentroids

    #6. Termina
    lw ra, 0(sp) #repor endereco de retorno
    addi sp, sp, 4 #libertar espaco na pilha
    jr ra


###initializeCentroids
#Inicializa os valores inicais do vetor centroids. Escolhe as coordenadas de k centroides aleatoriamente.
# Argumentos: nenhum
# Retorno: nenhum

initializeCentroids:
    la t3,centroids
    lw t4,k
    slli t4, t4, 1 #numero de coordenadas para colocar numeros aleatorios
    initializeCentroidsLoop:
        #vamos garantir a aleatoriedade atraves da leitura da diferenca entre 1-1-1970 00:00 ate a data atual
        li a7, 30  #utilizado no ecall da linha seguinte
        ecall      #faz com que o codigo leia a data e hora atual
        li t0, 32  #coordenada maxima
        remu t1, a0, t0    #t1 corresponde ao valor para armazenar
        li t2, 1000
        initializeCentroidsDelayLoop:               #introduzimos um delay para garantir a aleatoriedade
            addi t2, t2, -1
            bne x0,t2, initializeCentroidsDelayLoop
        sw t1, 0(t3)       #guarda o valor no vetor centroids
        addi t3,t3,4       #passa para o centroide seguinte
        addi t4,t4,-1      #tirar 1 do valor de k, ja que acabamos de analisar 1 ponto
        bne t4, x0, initializeCentroidsLoop
    jr ra


### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    sub t5, a2, a0 #t5 = x1 - x0
    sub t6, a3, a1 #t6 = y1 - y0
    blt t5, x0, manhattanDistanceModuleX #modulo de t5
    blt t6, x0, manhattanDistanceModuleY #modulo de t6
    j manhattanDistanceEnd #soma resultados positivos
    manhattanDistanceModuleX:
        neg t5,t5 #se for negativo, nega o resultado
        bge t6, x0, manhattanDistanceEnd #caso t6 seja negativo, salta para o fim da funcao
    manhattanDistanceModuleY:
        neg t6, t6 #se for negativo, nega o resultado
    manhattanDistanceEnd:
        add a0, t6, t5 #soma coordenadas
        jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    addi sp, sp, -4 #reservar espaco na pilha
    sw ra, 0(sp) #guardar endereco de retorno
    add a2, a0, x0 #trocar registo onde o ponto eh escrito
    add a3, a1, x0 #continuacao da troca
    la t0 centroids #load do vetor centroids
    lw t1 k #load do numero de centroides
    add t2, x0, x0 #indice
    add t3, x0, x0 #indice do centroide mais proximo
    addi t4, x0, 64 #distancia do centroide mais proximo
    nearestClusterLoop:
        beq t2, t1, nearestClusterEnd #terminar se chegar ao fim do vetor
        lw a0, 0(t0) #x0 toma o valor do primeiro elemento
        lw a1, 4(t0) #y0 toma o valor do segundo elemento
        jal manhattanDistance #distancia ao centroide atual
        bge a0, t4, nearestClusterDefault #se a distancia nao for menor, vai para o caso default
        add t3, t2, x0 #atualizar indice do centroide mais proximo
        add t4, a0, x0 #atualizar distancia do centroide mais proximo
    nearestClusterDefault:
        addi t0, t0, 8 #proximo ponto
        addi t2, t2, 1 #proximo indice
        j nearestClusterLoop #invocacao recursiva
    nearestClusterEnd:
        add a0, t3, x0 #retornar o indice do centroide mais proximo
        lw ra, 0(sp) #repor endereco de retorno
        addi sp, sp, 4 #libertar espaco na pilha
        jr ra #retorna ao ponto de invocacao


### mainKMeans
# Executa o algoritmo k-means.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    addi sp, sp, -4 #reservar espaco na pilha
    sw ra, 0(sp) #guardar endereco de retorno
    lw s1, L #load do numero de iteracoes restantes
    jal initializeCentroids #inicializa centroides com valores aleatorios
    
    mainKMeansLoop:
        #1. guardar os centroides anteriores para futura comparacao
        lw t0, k #load numero de clusters
        slli t0, t0, 1 #multiplicar por dois (para ter o numero de valores para guardar)
        la t1, centroids #load vetor centroids
        la t2, previous_centroids #load vetor para os centroids anteriores
        savePreviousCentroids:
            lw t3, 0(t1) #toma o primeiro valor do vetor centroids
            sw t3, 0(t2) #guarda no primeiro espaco do vetor para os centroids anteriores
            addi t1, t1, 4 #proximo valor
            addi t2, t2, 4 #proximo espaco
            addi t0, t0, -1 #menos um valor restante para guardar
            bne t0, x0, savePreviousCentroids #se houver valores para guardar, percorre novamente o loop
        
        #2. cleanScreen
        jal cleanScreen
        
        #3. aplicar nearestCluster em todos os pontos e atualizar vetor clusters
        la s2 points #load do vetor de pontos
        lw s3 n_points #load do numero de pontos restantes
        la s4 clusters #load do vetor do cluster de cada ponto
        mainNearestCluster:
            lw a0, 0(s2) #x toma o valor do primeiro elemento
            lw a1, 4(s2) #y toma o valor do segundo elemento
            jal nearestCluster #determinar centroide mais proximo
            sw a0, 0(s4) #guardar cluster calculado no vetor do cluster de cada ponto
            addi s2, s2, 8 #proximo ponto
            addi s4, s4, 4 #proximo cluster
            addi s3, s3, -1 #menos 1 ponto por ver
            bne x0, s3, mainNearestCluster #se houver pontos por ver, percorre novamente o loop
        
        #4. printClusters
        jal printClusters

        #5. calculateCentroids
        jal calculateCentroids

        #6. printCentroids
        jal printCentroids
    
        #7. verifica se eh necessario nova iteracao
        addi s1, s1, -1 #menos uma iteracao restante
        beq s1, x0, mainKMeansEnd #caso tenham sido feitas todas as iteracoes, termina
        lw t0, k #load numero de clusters
        slli t0, t0, 1 #multiplicar por dois (para ter o numero de valores para comparar)
        la t1, centroids #load vetor centroids
        la t2, previous_centroids #load vetor dos centroids anteriores
        compareCentroids:
            lw t3, 0(t1) #toma o primeiro valor do vetor centroids
            lw t4, 0(t2) #toma o primeiro valor do vetor dos centroids anteriores
            bne t3, t4, mainKMeansLoop #se houver diferencas, ocorre uma nova iteracao
            addi t1, t1, 4 #proximo valor do vetor centroids
            addi t2, t2, 4 #proximo valor do vetor dos centroids anteriores
            addi t0, t0, -1 #menos um valor restante para comparar
            bne t0, x0, compareCentroids #se houver valores para comparar, percorre novamente o loop
        
    mainKMeansEnd:
        #8. termina
        lw ra, 0(sp) #repor endereco de retorno
        addi sp, sp, 4 #libertar espaco na pilha
        jr ra