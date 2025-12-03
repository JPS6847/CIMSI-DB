CREATE TABLE IF NOT EXISTS usuarios (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombreUsuario VARCHAR(20) NOT NULL,
    contrasenya VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    fecha_registro DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    fotoPerfil TEXT NOT NULL DEFAULT 'images/perfiles/default_profile.png'
);

CREATE TABLE IF NOT EXISTS partituras (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    descripcion TEXT NOT NULL,
    usuario_id INT(11) NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON UPDATE RESTRICT ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS valoraciones (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    numEstrellas INT(11) NOT NULL,
    fecha DATE NOT NULL DEFAULT CURDATE(),
    partitura_id INT(11) NOT NULL,
    usuario_id INT(11) NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (partitura_id) REFERENCES partituras(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CHECK (numEstrellas BETWEEN 0 AND 5)
);

CREATE TABLE IF NOT EXISTS carritos (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT(11) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS comentarios (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    texto TEXT NOT NULL,
    valoracion_id INT(11) NOT NULL,
    parent_id INT(11) NULL,
    FOREIGN KEY (valoracion_id) REFERENCES valoraciones(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES comentarios(id)
        ON UPDATE RESTRICT ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS compras (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    totalCompra DECIMAL(10,2) NOT NULL,
    fecha_compra DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id INT(11) NOT NULL,
    estadoPago ENUM('pendiente','completado','fallido') DEFAULT 'pendiente',
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS imagenes (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    url TEXT NOT NULL,
    thumbnail_url VARCHAR(255) NULL,
    partitura_id INT(11) NOT NULL,
    FOREIGN KEY (partitura_id) REFERENCES partituras(id)
        ON UPDATE RESTRICT ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lineascarrito (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    carrito_id INT(11) NOT NULL,
    partitura_id INT(11) NOT NULL,
    cantidad INT(11) NOT NULL DEFAULT 1,
    FOREIGN KEY (carrito_id) REFERENCES carritos(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (partitura_id) REFERENCES partituras(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lineascompra (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    unidades INT(11) NOT NULL,
    partitura_id INT(11) NOT NULL,
    compra_id INT(11) NOT NULL,
    FOREIGN KEY (partitura_id) REFERENCES partituras(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (compra_id) REFERENCES compras(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS respuestas (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    texto TEXT NOT NULL,
    fecha DATE NOT NULL DEFAULT CURDATE(),
    comentario_id INT(11) NOT NULL,
    usuario_id INT(11) NOT NULL,
    FOREIGN KEY (comentario_id) REFERENCES comentarios(id)
        ON UPDATE RESTRICT ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON UPDATE RESTRICT ON DELETE CASCADE
);

CREATE OR REPLACE VIEW vista_valoraciones AS
SELECT 
    v.id AS valoracion_id,
    v.numEstrellas AS numEstrellas,
    v.fecha AS fecha_valoracion,
    v.partitura_id AS partitura_id,
    v.usuario_id AS usuario_id,
    c.texto AS comentario,
    u.nombreUsuario AS nombreUsuario
FROM valoraciones v
LEFT JOIN comentarios c ON c.valoracion_id = v.id
LEFT JOIN usuarios u ON u.id = v.usuario_id;

CREATE OR REPLACE VIEW vista_partituras_imagenes AS
SELECT 
    p.id AS id,
    p.nombre AS nombre,
    p.precio AS precio,
    p.fecha AS fecha,
    i.url AS url
FROM partituras p
LEFT JOIN imagenes i ON p.id = i.partitura_id;
