-- Crear base de datos SQL Server
CREATE DATABASE IF NOT EXISTS stockmasterbd;

USE stockmasterbd;
GO

-- Tabla Dirección
CREATE TABLE Direccion (
    direccion_id INT IDENTITY(1,1) PRIMARY KEY,
    via VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    comuna VARCHAR(50) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    departamento VARCHAR(50),
    CONSTRAINT chk_direccion_campos CHECK (
        LEN(via) > 0 AND
        LEN(numero) > 0 AND
        LEN(comuna) <= 15 AND
        LEN(ciudad) <= 15 AND
        LEN(pais) <= 10 AND
        LEN(departamento) <= 15 
    )
);

-- Tabla Persona
CREATE TABLE Persona (
    id_persona INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    rol VARCHAR(30) NOT NULL,
    contraseña VARCHAR(100) NOT NULL,
    CONSTRAINT chk_persona_nombre CHECK (LEN(nombre) >= 3),
    CONSTRAINT chk_persona_usuario CHECK (LEN(usuario) <= 20),
    CONSTRAINT chk_persona_rol CHECK (rol IN ('Administrador', 'Vendedor', 'Gerente', 'Operario')),
    CONSTRAINT chk_contraseña_longitud CHECK (LEN(contraseña) >= 8),
    CONSTRAINT chk_contraseña_mayuscula CHECK (contraseña LIKE '%[A-Z]%'),
    CONSTRAINT chk_contraseña_minuscula CHECK (contraseña LIKE '%[a-z]%'),
    CONSTRAINT chk_contraseña_numero CHECK (contraseña LIKE '%[0-9]%'),
    CONSTRAINT chk_contraseña_especial CHECK (contraseña LIKE '%[!@#$%^&*()_+\-=\[\]{};:''",.<>?/\|`~]%')
);

-- Tabla Cliente
CREATE TABLE Cliente (
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    direccion_id INT UNIQUE NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (direccion_id) REFERENCES Direccion(direccion_id) ON DELETE CASCADE,
    CONSTRAINT chk_cliente_rut CHECK (LEN(rut) >= 8),
    CONSTRAINT chk_cliente_nombre CHECK (LEN(nombre) >= 3),
    CONSTRAINT chk_cliente_telefono CHECK (telefono LIKE '[0-9+()-]%' OR telefono IS NULL)
);

-- Tabla Proveedor
CREATE TABLE Proveedor (
    rut VARCHAR(12) PRIMARY KEY,
    tipo_proveedor VARCHAR(50) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    pagina_web VARCHAR(100),
    direccion_id INT UNIQUE NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (direccion_id) REFERENCES Direccion(direccion_id) ON DELETE CASCADE,
    CONSTRAINT chk_proveedor_tipo CHECK (tipo_proveedor IN ('Natural', 'Jurídica')),
    CONSTRAINT chk_proveedor_rut CHECK (LEN(rut) >= 8),
    CONSTRAINT chk_proveedor_nombre CHECK (LEN(nombre) >= 3),
    CONSTRAINT chk_proveedor_telefono CHECK (telefono LIKE '[0-9+()-]%' AND LEN(telefono) <= 15),
    CONSTRAINT chk_proveedor_pagina CHECK (pagina_web LIKE 'http%' OR pagina_web IS NULL)
);

-- Tabla Artículo
CREATE TABLE Articulo (
    codigo VARCHAR(20) IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    rut_proveedor VARCHAR(12) NOT NULL,
    editor_id INT NOT NULL,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (rut_proveedor) REFERENCES Proveedor(rut) ON DELETE CASCADE,
    FOREIGN KEY (editor_id) REFERENCES Persona(id_persona),
    CONSTRAINT chk_articulo_codigo CHECK (LEN(codigo) <= 7),
    CONSTRAINT chk_articulo_precio CHECK (precio > 0),
    CONSTRAINT chk_articulo_stock CHECK (stock >= 0),
    CONSTRAINT chk_articulo_nombre CHECK (LEN(nombre) <= 20)
);

-- Tabla Categoría
CREATE TABLE Categoria (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    id_articulo VARCHAR(20) NOT NULL UNIQUE,
    descripcion VARCHAR(250) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    referencia VARCHAR(50),
    FOREIGN KEY (id_articulo) REFERENCES Articulo(codigo) ON DELETE CASCADE,
    CONSTRAINT chk_categoria_descripcion CHECK (LEN(descripcion) <= 250),
    CONSTRAINT chk_categoria_tipo CHECK (tipo IN ('Electrónica', 'Ropa', 'Alimentos', 'Otros'))
);

-- Tabla Venta
CREATE TABLE Venta (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    rut_cliente VARCHAR(12) NOT NULL,
    descuento NUMERIC(5,2) DEFAULT 0,
    monto_final NUMERIC(12,2) NOT NULL,
    id_persona INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'Completada',
    FOREIGN KEY (rut_cliente) REFERENCES Cliente(rut) ON DELETE CASCADE,
    FOREIGN KEY (id_persona) REFERENCES Persona(id_persona),
    CONSTRAINT chk_venta_descuento CHECK (descuento >= 0 AND descuento <= 100),
    CONSTRAINT chk_venta_monto CHECK (monto_final > 0),
    CONSTRAINT chk_venta_estado CHECK (estado IN ('Pendiente', 'Completada', 'Cancelada')),
    CONSTRAINT chk_venta_fecha CHECK (fecha <= CAST(GETDATE() AS DATE))
);

-- Tabla Detalle_Venta
CREATE TABLE Detalle_Venta (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    venta_id INT NOT NULL,
    id_articulo VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(12,2) NOT NULL,
    FOREIGN KEY (venta_id) REFERENCES Venta(id_venta) ON DELETE CASCADE,
    FOREIGN KEY (id_articulo) REFERENCES Articulo(codigo),
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario > 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal > 0)
);

-- Tabla Factura
CREATE TABLE Factura (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,
    venta_id INT NOT NULL UNIQUE,
    total NUMERIC(12,2) NOT NULL,
    fecha_emision DATETIME DEFAULT GETDATE(),
    estado VARCHAR(20) DEFAULT 'Activa',
    FOREIGN KEY (venta_id) REFERENCES Venta(id_venta) ON DELETE CASCADE,
    CONSTRAINT chk_factura_total CHECK (total > 0),
    CONSTRAINT chk_factura_estado CHECK (estado IN ('Activa', 'Cancelada', 'Anulada'))
);



