CREATE TABLE meta.entity (
    schema_name varchar(58) NOT NULL
,   entity_name varchar(58) NOT NULL
,   base_entity_name varchar(58) NOT NULL
,   entity_type_code char(2) NOT NULL
,   CONSTRAINT pk_entity PRIMARY KEY (entity_name)
,   CONSTRAINT fk_entity__schema FOREIGN KEY (schema_name) REFERENCES meta.schema(schema_name)
,   CONSTRAINT fk_entity__entity_type FOREIGN KEY (entity_type_code) REFERENCES meta.entity_type(entity_type_code)
,   CONSTRAINT chk_entity__base_entity_name_length CHECK (entity_type_code <> 'ba' OR char_length(entity_name) <= 55)
);