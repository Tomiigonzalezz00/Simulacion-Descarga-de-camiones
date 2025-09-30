# 🚚 Simulación de Descarga de Camiones en un Supermercado

**Carrera:** Ingeniería en Sistemas de Información (UTN FRD, 4° año)  
**Herramienta:** SimEvents (MATLAB / Simulink)  
**Equipo:** Tomas González, Hanna Pastor, Julieta Zaracho  

---

## 🎯 Objetivo
Modelar y simular el proceso de **descarga de camiones** en un supermercado para determinar la cantidad óptima de cuadrillas de trabajo que minimiza los costos operativos, considerando:

- Distribuciones de llegada y carga.
- Restricciones horarias y horas extras.
- Penalizaciones por incumplimiento de descarga.

---

## 🔍 Metodología
1. **Análisis de datos:**
   - Identificación de la distribución de llegada de camiones (prueba de bondad de ajuste → distribución exponencial con media 2,46 h).
   - Modelado de carga como variable aleatoria normal (media 20 tn, σ=3,5 tn).

2. **Construcción del modelo en SimEvents (MATLAB/Simulink):**
   - **Sources:** llegada de camiones.
   - **Atributos:** tipo de carga y volumen.
   - **Servers:** descarga según velocidad (A, B, C).
   - **Queues & Decision Points:** horarios, horas extras, multas.
   - **Sinks:** camiones descargados.

3. **Simulación y experimentación:**
   - Pruebas con 1 a 5 cuadrillas.
   - 35 réplicas por escenario.
   - Intervalos de confianza (95%) para validar costos.

---

## 📊 Resultados
- **Carga tipo A:** 1 cuadrilla óptima → costo en [\$576,81 ; \$606,66].
- **Carga tipo B:** 1 cuadrilla óptima → costo en [\$583,57 ; \$604,64].
- **Carga tipo C:** 2 cuadrillas óptimas → costo en [\$558,86 ; \$590,92].

✅ Se identificó la configuración que minimiza los costos sin incumplir restricciones horarias ni aumentar penalizaciones.

---

## 👨‍💻 Mis aportes
- **Codificación:** desarrollo del script en MATLAB para la simulación de eventos discretos.
- **Diagramas:** elaboración del diagrama de flujo y esquema del modelo en Simulink.
- **Documentación:** redacción del informe técnico (formulación del problema, hipótesis, análisis y resultados).

---

## 📂 Recursos
- [📄 Informe técnico (PDF)](./Informe_simulacion.pdf)  
- [⚙️ Modelo Simulink (.slx)](./v40.slx)

---

## 🚀 Aprendizajes clave
- Aplicación de teoría de **simulación de eventos discretos** en un problema real de ingeniería.
- Validación estadística (Chi-cuadrado, distribución exponencial, normalidad).
- Trabajo colaborativo y documentación profesional.

---

## 📌 Cómo correr el modelo
1. Abrir `v40.slx` en **MATLAB/Simulink**.
2. Configurar el bloque de simulación con los parámetros indicados en el informe.
3. Ejecutar la simulación y analizar los resultados.

---
