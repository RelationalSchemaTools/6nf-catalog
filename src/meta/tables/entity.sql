CREATE TABLE meta.entity (
    entity_name varchar(58) NOT NULL
,   entity_type_code char(2) NOT NULL
,   CONSTRAINT pk_entity PRIMARY KEY (entity_name)
,   CONSTRAINT fk_entity__entity_type FOREIGN KEY (entity_type_code) REFERENCES meta.entity_type(entity_type_code)
);