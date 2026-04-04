-- Crear base de datos SQL Server
IF OBJECT_ID('STOCKMASTERBD') is not null
 drop database STOCKMASTER_BD
create database STOCKMASTER_BD;-- Tabla Dirección
GO
use STOCKMASTER_BD
GO
    CREATE TABLE Direccion (
        direccion_id INT IDENTITY(1, 1) PRIMARY KEY,
        via VARCHAR(100) NOT NULL,
        numero VARCHAR(10) NOT NULL,
        comuna VARCHAR(50) NOT NULL,
        ciudad VARCHAR(50) NOT NULL,
        pais VARCHAR(50) NOT NULL,
        departamento VARCHAR(50),
        CONSTRAINT chk_direccion_campos CHECK (
            LEN(via) > 0
            AND LEN(numero) > 0
            AND LEN(comuna) <= 15
            AND LEN(ciudad) <= 15
            AND LEN(pais) <= 10
            AND LEN(departamento) <= 15
        )
    );
-- Tabla Persona

CREATE TABLE Persona (
    id_persona INT IDENTITY(1, 1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    rol VARCHAR(30) NOT NULL,
    contraseña VARCHAR(100) NOT NULL,
    CONSTRAINT chk_persona_nombre CHECK (LEN(nombre) >= 3),
    CONSTRAINT chk_persona_usuario CHECK (LEN(usuario) <= 20),
    CONSTRAINT chk_persona_rol CHECK (
        rol IN (
            'Administrador',
            'Vendedor',
            'Gerente',
            'Operario'
        )
    ),
    CONSTRAINT chk_contraseña_longitud CHECK (LEN(contraseña) >= 8),
    CONSTRAINT chk_contraseña_mayuscula CHECK (contraseña LIKE '%[A-Z]%'),
    CONSTRAINT chk_contraseña_minuscula CHECK (contraseña LIKE '%[a-z]%'),
    CONSTRAINT chk_contraseña_numero CHECK (contraseña LIKE '%[0-9]%')
    --CONSTRAINT chk_contraseña_especial CHECK (
        --contraseña LIKE '%[!@#$%^&*()_+\-=\[\]{};:''",.<>?/\|`~]%'
    --) --todavia no funciona el check de caracteres especiales
);
-- Tabla Cliente
CREATE TABLE Cliente (
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    direccion_id INT UNIQUE NOT NULL FOREIGN KEY REFERENCES Direccion(direccion_id) ON DELETE CASCADE,
    CONSTRAINT chk_cliente_rut CHECK (LEN(rut) >= 8),
    CONSTRAINT chk_cliente_nombre CHECK (LEN(nombre) >= 3),
    CONSTRAINT chk_cliente_telefono CHECK (
        telefono LIKE '[0-9+()-]%'
        OR telefono IS NULL
    )
);
-- Tabla Proveedor
CREATE TABLE Proveedor (
    rut VARCHAR(12) PRIMARY KEY,
    tipo_proveedor VARCHAR(50) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    pagina_web VARCHAR(100),
    direccion_id INT UNIQUE NOT NULL FOREIGN KEY REFERENCES Direccion(direccion_id) ON DELETE CASCADE,
    fecha_registro DATETIME DEFAULT GETDATE(),
    CONSTRAINT chk_proveedor_tipo CHECK (tipo_proveedor IN ('Natural', 'Jurídica')),
    CONSTRAINT chk_proveedor_rut CHECK (LEN(rut) >= 8),
    CONSTRAINT chk_proveedor_nombre CHECK (LEN(nombre) >= 3),
    CONSTRAINT chk_proveedor_telefono CHECK (
        telefono LIKE '[0-9+()-]%'
        AND LEN(telefono) <= 15
    ),
    CONSTRAINT chk_proveedor_pagina CHECK (
        pagina_web LIKE 'http%'
        OR pagina_web IS NULL
    )
);
-- Tabla Artículo
CREATE TABLE Articulo (
    codigo INT IDENTITY(1, 1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(18, 0) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    rut_proveedor VARCHAR(12) NOT NULL FOREIGN KEY REFERENCES Proveedor(rut) ON DELETE CASCADE,
    editor_id INT NOT NULL FOREIGN KEY REFERENCES Persona(id_persona),
    fecha_creacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT chk_articulo_codigo CHECK (LEN(codigo) <= 7),
    CONSTRAINT chk_articulo_precio CHECK (precio > 0),
    CONSTRAINT chk_articulo_stock CHECK (stock >= 0),
    CONSTRAINT chk_articulo_nombre CHECK (LEN(nombre) <= 20)
);
-- Tabla Categoría
CREATE TABLE Categoria (
    id_categoria INT IDENTITY(1, 1) PRIMARY KEY,
    id_articulo INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Articulo(codigo) ON DELETE CASCADE,
    descripcion VARCHAR(250) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    referencia VARCHAR(50),
    CONSTRAINT chk_categoria_descripcion CHECK (LEN(descripcion) <= 250),
    CONSTRAINT chk_categoria_tipo CHECK (
        tipo IN (
            'Módulos',
            'Controladores',
            'Fuentes de poder',
            'Tarjetas',
            'Cables',
            'Estructuras',
            'Distribución',
            'Conectores',
            'Pantallas',
            'Software',
            'Otros'
        )
    )
);
-- Tabla Venta
CREATE TABLE Venta (
    id_venta INT IDENTITY(1, 1) PRIMARY KEY,
    fecha DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    rut_cliente VARCHAR(12) NOT NULL FOREIGN KEY REFERENCES Cliente(rut) ON DELETE CASCADE,
    descuento NUMERIC(3, 2) DEFAULT 0,
    valor NUMERIC(18, 0) NOT NULL,
    id_persona INT NOT NULL FOREIGN KEY REFERENCES Persona(id_persona),
    estado VARCHAR(20) DEFAULT 'Completada',
    CONSTRAINT chk_venta_descuento CHECK (
        descuento >= 0
        AND descuento <= 1
    ),
    CONSTRAINT chk_venta_monto CHECK (valor > 0),
    CONSTRAINT chk_venta_estado CHECK (
        estado IN ('Pendiente', 'Completada', 'Cancelada')
    ),
    CONSTRAINT chk_venta_fecha CHECK (fecha <= CAST(GETDATE() AS DATE))
);

-- Tabla Detalle_Venta
CREATE TABLE Detalle_Venta (
    id_detalle INT IDENTITY(1, 1) PRIMARY KEY,
    venta_id INT NOT NULL FOREIGN KEY REFERENCES Venta(id_venta) ON DELETE CASCADE,
    id_articulo INT NOT NULL FOREIGN KEY REFERENCES Articulo(codigo),
    cantidad INT NOT NULL,
    precio_unitario NUMERIC(18, 0) NOT NULL,
    subtotal NUMERIC(18, 0) NOT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario > 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal > 0)
);
-- Tabla Factura
CREATE TABLE Factura (
    id_factura INT IDENTITY(1, 1) PRIMARY KEY,
    venta_id INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Venta(id_venta) ON DELETE CASCADE,
    total NUMERIC(18, 0) NOT NULL,
    fecha_emision DATETIME DEFAULT GETDATE()
    CONSTRAINT chk_factura_total CHECK (total > 0)
);


-- ==========================================
-- INSERTAR REGISTROS EN LA BASE DE DATOS
-- ==========================================

-- Insertar Direcciones
INSERT INTO Direccion (via, numero, comuna, ciudad, pais, departamento)
VALUES 
    ('Avenida Principal', '123', 'Santiago', 'Santiago', 'Chile', 'Metropolitana'),
    ('Calle Centro', '456', 'Providencia', 'Santiago', 'Chile', 'Metropolitana'),
    ('Pasaje Industrial', '789', 'Maipú', 'Santiago', 'Chile', 'Metropolitana'),
    ('Avenida Este', '321', 'Las Condes', 'Santiago', 'Chile', 'Metropolitana'),
    ('Calle Sur', '654', 'Ñuñoa', 'Santiago', 'Chile', 'Metropolitana'),
    ('Avenida Valparaíso', '987', 'Valparaíso', 'Valparaíso', 'Chile', 'Valparaíso'),
    ('Calle Comercial', '111', 'Concepción', 'Concepción', 'Chile', 'Bío-Bío');

-- Insertar Personas (Usuarios del sistema)
INSERT INTO Persona (nombre, usuario, rol, contraseña)
VALUES 
    ('Juan García López', 'jgarcia', 'Administrador', 'Admin@2024!'),
    ('María Rodríguez Santos', 'mrodriguez', 'Gerente', 'Gerente#123'),
    ('Carlos Martínez Pérez', 'cmartinez', 'Vendedor', 'Vend0r@2024'),
    ('Ana Fernández Silva', 'afernandez', 'Vendedor', 'Ana#Fern123'),
    ('Roberto López Díaz', 'rlopez', 'Operario', 'Oper@rio_2024'),
    ('Patricia Torres Ruiz', 'ptorres', 'Vendedor', 'Torr3s$2024');

-- Insertar Clientes
INSERT INTO Cliente (rut, nombre, telefono, direccion_id)
VALUES 
    ('10.123.456-1', 'Cliente Industrial S.A.', '22-5544332', 1),
    ('12.345.678-2', 'ElectrónicosXL', '9-87654321', 2),
    ('14.567.890-4', 'Distribuidora Técnica', '22-3344556', 3),
    ('16.789.012-5', 'Soluciones Automáticas', '9-12345678', 4),
    ('18.901.234-7', 'TechMasters', '22-9988776', 5);

-- Insertar Proveedores
INSERT INTO Proveedor (rut, tipo_proveedor, nombre, telefono, pagina_web, direccion_id)
VALUES 
    ('20.111.222-K', 'Natural', 'Componentes Electrónicos SA', '22-2222222', 'https://www.compelectronicos.co', 6),
    ('21.333.444-9', 'Jurídica', 'Industrias Modular', '56-987654321', 'https://www.modalur.co', 7),
    ('22.555.666-3', 'Natural', 'Juan Supplies', '9-11111111', 'https://www.juansupplies.com', 1),
    ('23.777.888-8', 'Jurídica', 'Global Imports Tech', '22-3333333', 'https://www.globalimports.com', 2);

-- Insertar Artículos
INSERT INTO Articulo (nombre, precio, stock, rut_proveedor, editor_id)
VALUES 
    ('Módulo PLC', 450000, 25, '20.111.222-K', 1),
    ('Controlador SCADA', 1250000, 10, '20.111.222-K', 2),
    ('Fuente Industrial', 35000, 40, '21.333.444-9', 3),
    ('Tarjeta HMI', 89025, 15, '21.333.444-9', 4),
    ('Cable Cat6', 1250, 200, '22.555.666-3', 5),
    ('Conector M12', 2500, 150, '22.555.666-3', 5),
    ('Estructura Aluminio', 15000, 30, '23.777.888-8', 6),
    ('Pantalla Táctil', 2500.00, 8, '20.111.222-K', 6),
    ('Software SCADA', 5000.00, 5, '23.777.888-8', 5),
    ('Relé de Control', 45.75, 100, '21.333.444-9', 4);

-- revisar que coincidad el id del articulo
-- Insertar Categorías
INSERT INTO Categoria (id_articulo, descripcion, tipo, referencia)
VALUES 
    (5, 'Módulo programable compacto', 'Módulos', 'MOD-001'),
    (6, 'Controlador SCADA avanzado', 'Controladores', 'CTRL-001'),
    (7, 'Fuente estabilizada 24V', 'Fuentes de poder', 'PSU-001'),
    (8, 'Interfaz HMI 7 pulgadas', 'Pantallas', 'HMI-001'),
    (9, 'Cable de red categoría 6', 'Cables', 'CAB-001'),
    (10, 'Conector industrial M12', 'Conectores', 'CON-001'),
    (11, 'Perfiles de aluminio', 'Estructuras', 'STR-001'),
    (12, 'Monitor táctil industrial', 'Pantallas', 'PANT-001'),
    (13, 'Software de supervisión', 'Software', 'SOFT-001'),
    (14, 'Relé electromecánico', 'Controladores', 'RELE-001');

--revisar que coincida el id_persona
-- Insertar Ventas
INSERT INTO Venta (fecha, rut_cliente, descuento, valor, id_persona, estado)
VALUES 
    ('2024-03-01', '10.123.456-1', 0.5, 1710000.00, 1, 'Completada'),
    ('2024-03-05', '12.345.678-2', 0.00, 1335025.00, 3, 'Completada'),
    ('2024-03-10', '14.567.890-4', 0.1, 2610000.00, 2, 'Completada'),
    ('2024-03-15', '16.789.012-5', 0.35, 6887275.00, 4, 'Completada'),
    ('2024-03-20', '18.901.234-7', 0.00, 7905000.00, 5, 'Completada'),
    ('2024-03-25', '10.123.456-1', 0.08, 1840000.00, 3, 'Completada');

--revisar que coincida id_articulo con el precio
-- Insertar Detalles de Venta con precios correctos
INSERT INTO Detalle_Venta (venta_id, id_articulo, cantidad, precio_unitario, subtotal)
VALUES 
    -- Venta 1: Cliente Industrial con descuento 5%
    (1, 5, 3, 450000, 1350000),
    (1, 9, 5, 1250, 6250),
    (1, 10, 10, 2500, 25000),
    
    -- Venta 2: ElectrónicosXL sin descuento
    (2, 7, 2, 35000, 70000),
    (2, 14, 8, 45.75, 366.00),
    (2, 8, 12, 89025, 1068300),
    (2, 9, 50, 1250, 62500),
    (2, 11, 3, 15000, 45000),
    
    -- Venta 3: Distribuidora Técnica con descuento 10%
    (3, 6, 1, 1250000, 1250000),
    (3, 8, 2, 89025, 178050),
    (3, 10, 1, 2500.00, 2500.00),
    (3, 13, 1, 5000.00, 5000.00),
    
    -- Venta 4: Soluciones Automáticas con descuento 3.5%
    (4, 11, 5, 15000, 75000),
    (4, 10, 2, 2500.00, 5000.00),
    (4, 7, 3, 35000, 105000),
    (4, 5, 12, 450000, 5400000),
    (4, 10, 20, 2500, 50000),
    
    -- Venta 5: TechMasters sin descuento
    (5, 13, 1, 5000.00, 5000.00),
    (5, 5, 2, 450000, 900000),
    (5, 6, 5, 1250000, 6250000),
    
    -- Venta 6: Cliente Industrial con descuento 8%
    (6, 9, 100, 1250, 125000),
    (6, 10, 30, 2500, 75000),
    (6, 7, 15, 35000, 525000),
    (6, 8, 8, 89025, 712200),
    (6, 14, 15, 45.75, 686.25);

-- Insertar Facturas con totales correctos
INSERT INTO Factura (venta_id, total)
VALUES 
    (1, 1710000.00),
    (2, 1335025.00),
    (3, 2610000.00),
    (4, 6887275.00),
    (5, 7905000.00),
    (6, 1840000.00);

-- Mensaje de confirmación
PRINT '========================================';
PRINT 'Base de datos poblada correctamente';
PRINT '========================================';
PRINT 'Direcciones insertadas: 7';
PRINT 'Personas insertadas: 6';
PRINT 'Clientes insertados: 5';
PRINT 'Proveedores insertados: 4';
PRINT 'Artículos insertados: 10';
PRINT 'Categorías insertadas: 10';
PRINT 'Ventas insertadas: 6';
PRINT 'Detalles de venta insertados: 13';
PRINT 'Facturas insertadas: 6';
PRINT '========================================';


GO