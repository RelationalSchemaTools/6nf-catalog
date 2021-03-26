CREATE TABLE meta.entity_type (
    entity_type_code char(2) NOT NULL
,   name varchar(100) NOT NULL
,   primary_key_data_type varchar(100) NOT NULL
,   CONSTRAINT pk_entity_type PRIMARY KEY (entity_type_code)
);

CREATE UNIQUE INDEX ux_entity_type__name ON meta.entity_type (name);