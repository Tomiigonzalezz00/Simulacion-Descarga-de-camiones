% Nombre del modelo de Simulink
modelo = 'V40';

% Nombres de los bloques que usan la semilla
bloques = {... 
    [modelo, '/TC'], ...
    [modelo, '/CC'], ...
    [modelo, '/LC']};

% Cargar el modelo
load_system(modelo);

% Configurar el tiempo de simulación
set_param(modelo, 'StopTime', '40360');  

% Configurar cantidad total de simulaciones
M = 164; % Cantidad total de simulaciones

% Crear tiempo y valores para ContieneCarga
tiempo = 0;           % Tiempos de inicio y fin
Tiene = 1;           
ContieneCarga = [tiempo, Tiene];  % 1 = Sin carga, 2 = Con carga 
assignin('base', 'ContieneCarga', ContieneCarga);

% Inicializar variables
CantCuadrillas = [0, 1; 40360, 1]; % Inicializar CantCuadrillas como constante
assignin('base', 'CantCuadrillas', CantCuadrillas);

% Ruta para el archivo Excel
outputPath = 'C:\Users\tomii\Desktop'; % Ruta correspondiente
outputFile = fullfile(outputPath, 'resultados_simulaciones.xlsx');

% Eliminar el archivo si ya existe
if exist(outputFile, 'file') == 2
    delete(outputFile); % Elimina el archivo para evitar problemas de bloqueo
    disp(['Archivo eliminado: ' outputFile]);
end

% Ejecutar simulaciones y generar una hoja por cada valor de M
for i = 1:M
    %En esta parte se debe descomentar lo que esta abajo para que vaya
    %incrementando de a una cuadrilla.
    % Incrementar CantCuadrillas si i es múltiplo  
    %if mod(i, 35) == 1 && i > 1 %El numero despues de la coma indica la cantidad de simulaciones por cuadrilla
     %   nuevo_valor = CantCuadrillas(1, 2) + 1; % Incrementar el valor de CantCuadrilla
      %  CantCuadrillas = [0, nuevo_valor; 40360, nuevo_valor]; % Mantener constante a lo largo del tiempo
       % assignin('base', 'CantCuadrillas', CantCuadrillas); % Actualizar en el workspace
    %end
    CantCuadrillas(1, 2) = 1; %Asi utilizamos la cantidad de cuadrilla fija
    % Cambiar la semilla para cada bloque
    for j = 1:length(bloques)
        nueva_semilla = randi([100000, 500000]);  
        set_param(bloques{j}, 'Seed', num2str(nueva_semilla));
    end

    % Ejecutar la simulación
    simOut = sim(modelo, 'ReturnWorkspaceOutputs', 'on');

    % Obtener los valores de ID, TI y TS desde la simulación
    ID = simOut.get('ID').Data; % ID de entidad
    TI = simOut.get('TI').Data; % Tiempo Inicial
    TS = simOut.get('TS').Data; % Tiempo del Servidor
    Carga = simOut.get('Carga').Data;
    TipoCarga = simOut.get('TipoCarga').Data;
    CargaInicial = Carga;

    % Filtrar entidades con CargaInicial igual a 0 
    valid_indices = CargaInicial ~= 0;
    ID = ID(valid_indices);
    TI = TI(valid_indices);
    TS = TS(valid_indices);
    Carga = Carga(valid_indices);
    TipoCarga = TipoCarga(valid_indices);
    CargaInicial = CargaInicial(valid_indices);

    % Calcular el Tiempo Total
    TiempoTotal = TI + TS; % Es el tiempo en el que finalizaría la descarga

    % Agregar CantCuadrillas a cada entidad
    CantCuadrillas_actual = CantCuadrillas(1, 2) * ones(size(ID));

    % Inicializar vectores para la simulación actual
    CantidadHorasNormales = zeros(size(ID));
    CantidadHorasExtras = zeros(size(ID));
    CostoHoraExtra = zeros(size(ID));
    CostoHoraNormal = zeros(size(ID));
    CostoAyudantes = zeros(size(ID));
    CostoOperador = zeros(size(ID));
    CostoTotal = zeros(size(ID));    
    CostoMulta = zeros(size(ID));
    
    for k = 1:length(ID)
        % Calculo de la velocidad según tipo de carga
        if TipoCarga(k) == 1
            VelocidadDesc(k) = 6 / 60;
        elseif TipoCarga(k) == 2
            VelocidadDesc(k) = 5.5 / 60;
        elseif TipoCarga(k) == 3
            VelocidadDesc(k) = 3.5 / 60;
        end 
        
        % Verificar la condición usando el valor del ID
        if TI(k) <= 1020 % Si entra después de las 5 pasa al otro día
            if TiempoTotal(k) <= 1080  % el TS no se pasa de las 6pm 
                % Dentro del horario normal
                CantidadHorasNormales(k) = TS(k);
                CantidadHorasExtras(k) = 0;
                CostoOperador = 0.66 * CantCuadrillas_actual(k);
                CostoAyudantes = 0.9 * CantCuadrillas_actual(k);
                CostoTotalMDO = CostoOperador + 2 * CostoAyudantes;
                CostoHoraNormal = CantidadHorasNormales(k) * CostoTotalMDO;
                CostoTotal(k) = CostoHoraNormal;
            else
                % Manejar horas extra
                CantidadHorasNormales(k) = 1080 - TI(k);
                CantidadHorasExtras(k) = TS(k) - CantidadHorasNormales(k);
                CostoOperador = 0.66 * 0.75 * CantCuadrillas_actual(k);
                CostoAyudantes = 0.9 * 0.75 * CantCuadrillas_actual(k);
                if CantidadHorasExtras(k) > 180 && TI(k) < 900 %se necesitan mas de tres horas
                    CostoMulta(k) = 4500;
                else
                    CostoMulta(k) = 0;
                end
            end
            
            CostoHoraExtra(k) = CantidadHorasExtras(k) * 2.2;
            CostoHoraNormal(k) = CantidadHorasNormales(k)*(CostoOperador + 2 * CostoAyudantes);
            CostoTotal(k) = CostoHoraNormal(k) + CostoHoraExtra(k) + CostoMulta(k);
        end
    end
    
    % Crear tabla con los resultados acumulados de esta simulación
    tabla_simulacion = table(ID, CostoTotal, CargaInicial, Carga, TI, TS, TiempoTotal, ...
        CantidadHorasNormales, CantidadHorasExtras, CantCuadrillas_actual, TipoCarga, ...
        'VariableNames', {'ID', 'CostoTotal', 'CargaInicial', 'Carga', 'TI', 'TS', 'TiempoTotal', 'CantidadHorasNormales', 'CantidadHorasExtras', 'CantCuadrillas', 'TipoCarga'});
    
    % Crear nombre dinámico para la hoja de Excel
    sheetName = ['Simulacion_' num2str(i)];

    % Escribir la tabla en Excel
    try
        writetable(tabla_simulacion, outputFile, 'Sheet', sheetName);
        disp(['Hoja ' sheetName ' escrita correctamente en ' outputFile]);
    catch ME
        warning(['Error escribiendo en el archivo Excel: ' ME.message]);
    end
end

