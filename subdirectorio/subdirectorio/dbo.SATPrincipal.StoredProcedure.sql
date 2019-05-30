USE [Autorizador30]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Nombre: SATPrincipal
-- Descripción: Procesamiento del Paquete, modulo inicial del Autorizador
-- Modificaciones:
-- Fecha      Versión Autor      Detalle
-- 12/10/2016   01    Pablo Díaz Elaboración
create procedure [dbo].[SATPrincipal]
   @PaqIn1 varchar(256),
   @PaqIn2 varchar(256),
   @PaqIn3 varchar(256),
   @PaqIn4 varchar(256),
   @PaqOut1 varchar(256) output,
   @PaqOut2 varchar(256) output,
   @PaqOut3 varchar(256) output,
   @PaqOut4 varchar(256) output
as
---------------------------
-- Declaracion de variables
---------------------------
declare @IdPaq int
declare @PaqIn varchar(1024)
declare @PaqOut varchar(1024)
declare @LenOut int
declare @sep char(1)
declare @TipoMenIn varchar(4)  -- Tipo de Mensaje del paquete de entrada
declare @TipoMenOut varchar(4) -- Tipo de Mensaje del paquete de salida
declare @Tarjeta varchar(20)   -- Número de Tarjeta
declare @CodPro varchar(6)     -- Código de Procesamiento
declare @Importe varchar(12)   -- Importe de la Transacción
declare @FechaHora varchar(10) -- Fecha y Hora de la Transmisión: Formato MMDDhhmmss
declare @Trace varchar(6)      -- Número del Trace del Sistema
declare @Hora varchar(6)       -- Hora Local de la Transacción: Formato hhmmss
declare @Fecha varchar(4)      -- Fecha Local de la Transacción: Formato MMDD
declare @Expiracion varchar(4) -- Fecha de Expiración: Formato AAMM
declare @ModoIng varchar(3)    -- Modo de Ingreso
declare @IIRed varchar(3)      -- Identificador Internacional de la Red
declare @CodCond varchar(2)    -- Código de condición de la POS
declare @Track2 varchar(37)    -- Datos del TRACK II
declare @RRN varchar(12)       -- Retrieval Reference Number
declare @Terminal varchar(8)   -- Número de la Terminal
declare @Comercio varchar(15)  -- Número de Comercio
declare @CodPlan varchar(1)    -- Código de Plan
declare @Cuotas varchar(2)     -- Cantidad de Cuotas
declare @Moneda varchar(3)     -- Código de Moneda
declare @CVV1 varchar(6)       -- Código de Seguridad de la banda magnética
declare @CVV2 varchar(6)       -- Código de Seguridad de la Tarjeta
--declare @VerSoft varchar(25)   -- Versión de Software
declare @Ticket varchar(4)     -- Número de Ticket
declare @PosDatado varchar(6)  -- Fecha de Pos Datado: Formato DDMMAA
declare @Efectivo varchar(12)  -- Monto de Entrega en Efectivo
declare @CodRazon varchar(4)   -- Código de Razón: motivo de la comunicación
declare @AñoFechor varchar(12) -- Año Fecha y Hora de la Transmisión
declare @Canal varchar(20)     -- Canal de ingreso de la transacción: Valores POS/IVR/MOVIPOS/Otro
declare @TipoMenOri varchar(4) -- Tipo de Mensaje de la Transacción Original
declare @FechaOri varchar(6)   -- Fecha Local de la Transacción Original: Formato AAMMDD
declare @HoraOri varchar(6)    -- Hora Local de la Transacción Original: Formato hhmmss
declare @TraceOri varchar(6)   -- Número del Trace de la Transacción Original
declare @TicketOri varchar(6)  -- Número de Ticket de la Transacción Original
declare @CodAutOff varchar(6)  -- Código de Autorización off-line
declare @CodAut varchar(6)     -- Código de Autorización
declare @CodRes varchar(2)     -- Código de Respuesta
declare @Mensaje varchar(100)  -- Mensaje de Respuesta
---------------------------------------
-- 1. Se registra el paquete de entrada
---------------------------------------
set @PaqIn=rtrim(ltrim(@PaqIn1))
if len(rtrim(ltrim(@PaqIn2)))>1
   begin
      set @PaqIn=@PaqIn+rtrim(ltrim(@PaqIn2))
      if len(rtrim(ltrim(@PaqIn3)))>1
         begin
            set @PaqIn=@PaqIn+rtrim(ltrim(@PaqIn3))
            if len(rtrim(ltrim(@PaqIn4)))>1
               set @PaqIn=@PaqIn+rtrim(ltrim(@PaqIn4))
         end
   end
insert into aut_Paquetes (FechorIn, PaqIn)
values (getdate(), @PaqIn)
set @IdPaq=@@identity
---------------------------
-- 2. Se desarma el paquete
---------------------------
exec aut_ExtraerCampo @PaqIn,'DITIPMEN',@TipoMenIn output
exec aut_ExtraerCampo @PaqIn,'DINUMTAR',@Tarjeta output
exec aut_ExtraerCampo @PaqIn,'DICODPRO',@CodPro output
exec aut_ExtraerCampo @PaqIn,'DIVALOR', @Importe output
exec aut_ExtraerCampo @PaqIn,'DIFECHOR',@FechaHora output
exec aut_ExtraerCampo @PaqIn,'DITRACE', @Trace output
exec aut_ExtraerCampo @PaqIn,'DIHORA',  @Hora output
exec aut_ExtraerCampo @PaqIn,'DIFECHA', @Fecha output
exec aut_ExtraerCampo @PaqIn,'DIFECEXP',@Expiracion output
exec aut_ExtraerCampo @PaqIn,'DIMODING',@ModoIng output
exec aut_ExtraerCampo @PaqIn,'DIIIRED', @IIRed output
exec aut_ExtraerCampo @PaqIn,'DICODCON',@CodCond output
exec aut_ExtraerCampo @PaqIn,'DITRACK2',@Track2 output
exec aut_ExtraerCampo @PaqIn,'DIRRN',   @RRN output
exec aut_ExtraerCampo @PaqIn,'DINUMTCT',@Terminal output
exec aut_ExtraerCampo @PaqIn,'DINUMCOM',@Comercio output
exec aut_ExtraerCampo @PaqIn,'DIPLPAGO',@CodPlan output
exec aut_ExtraerCampo @PaqIn,'DINUMCUO',@Cuotas output
exec aut_ExtraerCampo @PaqIn,'DIMONEDA',@Moneda output
exec aut_ExtraerCampo @PaqIn,'DICODSEG',@CVV1 output
exec aut_ExtraerCampo @PaqIn,'DICVV2',  @CVV2 output
--exec aut_ExtraerCampo @PaqIn,'soft',    @VerSoft output
exec aut_ExtraerCampo @PaqIn,'DITICKET',@Ticket output
exec aut_ExtraerCampo @PaqIn,'DIFECPDT',@PosDatado output
exec aut_ExtraerCampo @PaqIn,'DIMONEFC',@Efectivo output
exec aut_ExtraerCampo @PaqIn,'DIRAZCDE',@CodRazon output
exec aut_ExtraerCampo @PaqIn,'DIYYFFHH',@AñoFechor output
exec aut_ExtraerCampo @PaqIn,'DISOFT',  @Canal output
exec aut_ExtraerCampo @PaqIn,'DIORIMEN',@TipoMenOri output
exec aut_ExtraerCampo @PaqIn,'DIORIFEC',@FechaOri output
exec aut_ExtraerCampo @PaqIn,'DIORIHOR',@HoraOri output
exec aut_ExtraerCampo @PaqIn,'DIORITRA',@TraceOri output
exec aut_ExtraerCampo @PaqIn,'DIORITIC',@TicketOri output
exec aut_ExtraerCampo @PaqIn,'DICODAUT',@CodAutOff output

-- 30/05/2019 EJTurelli
-- Se fija el Plan en 'A' de acuerdo a lo solicitado por la marca
set @CodPlan = 'A'

-------------------------------
-- 3. Se procesa la transacción
-------------------------------
exec aut_Main
   null,              -- UUID: para futuro uso
   'L',               -- Tipo de Autorizador: Primario ó Local
   null,              -- FechorInOrigen: para futuro uso
   null,              -- VinculoOrigen: para futuro uso
   @TipoMenIn,
   @Tarjeta,
   @CodPro,
   @Importe,
   @FechaHora,
   @Trace,
   @Hora,
   @Fecha,
   @Expiracion,
   @ModoIng,
   @IIRed,
   @CodCond,
   @Track2,
   @RRN,
   @Terminal,
   @Comercio,
   @CodPlan,
   @Cuotas,
   @Moneda,
   @CVV1,
   @CVV2,
   null,              -- VerSoft: para futuro uso
   @Ticket,
   @PosDatado,
   @Efectivo,
   @CodRazon,
   @AñoFechor,
   @Canal,
   @TipoMenOri,
   @FechaOri,
   @HoraOri,
   @TraceOri,
   @TicketOri,
   @CodAutOff,
   @CodAut OUTPUT,
   @CodRes OUTPUT,
   @Mensaje OUTPUT
----------------------------------
-- 4. Se arma el paquete de salida
----------------------------------
set @sep=char(28) -- separador de campo
-- se calcula el Tipo de Mensaje del paquete de salida
set @TipoMenOut=@TipoMenIn+10
set @TipoMenOut=replicate('0',4-len(@TipoMenOut))+@TipoMenOut -- se completa con ceros a la izq hasta 4 digitos
-- se copia el paquete de entrada al de salida reemplazando el Tipo de Mensaje y sacando los primeros 4 digitos de tamaño del paquete
set @PaqOut=replace(substring(@PaqIn,5,len(@PaqIn)-4),'ditipmen='+@TipoMenIn,'ditipmen='+@TipoMenOut)
-- en respuesta de transacción offline se saca el código de autorización que viene del paquete de entrada
if len(@CodAutOff)>0
   set @PaqOut=replace(@PaqOut,'dicodaut='+@CodAutOff+@sep,'')
-- se agregan los campos de la respuesta, al primer campo no se le antepone un separador porque ya trae del paquete de entrada
set @PaqOut=@PaqOut+'diclave=LOCAL' -- reuso de variable para identificar en el host que la tx fue procesada por un aut local
if len(@CodAut)>0
   set @PaqOut=@PaqOut+@sep+'dicodaut='+@CodAut
if len(@CodRes)>0
   set @PaqOut=@PaqOut+@sep+'dicodres='+@CodRes
if len(@Mensaje)>0
   set @PaqOut=@PaqOut+@sep+'dimensaj='+@Mensaje
set @PaqOut=@PaqOut+@sep -- separador final
-- se agrega 4 digitos de tamaño del paquete completados con ceros a la izq
set @LenOut=len(@PaqOut)+4 -- se tienen en cuenta los 4 digitos de la longitud
set @PaqOut=replicate('0',4-len(@LenOut))+convert(varchar,@LenOut)+@PaqOut
----------------------------
-- 5. Se registra el paquete
----------------------------
update aut_Paquetes
set FechorOut=getdate(), PaqOut=@PaqOut
where Id=@IdPaq
----------------------------
-- 6. Se devuelve el paquete
----------------------------
-- se divide el paquete de salida en los 4 parametros
set @PaqOut1=substring(@PaqOut,1,255)
if len(@PaqOut)>255
   begin
      set @PaqOut2=substring(@PaqOut,255+1,255)
      if len(@PaqOut)>255*2
         begin
            set @PaqOut3=substring(@PaqOut,(255*2)+1,255)
            if len(@PaqOut)>255*3
               set @PaqOut4=substring(@PaqOut,(255*3)+1,255)
         end
   end

GO
