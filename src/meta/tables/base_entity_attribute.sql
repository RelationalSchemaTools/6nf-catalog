CREATE TABLE meta.base_entity_attribute (
    schema_name varchar(58) NOT NULL
,   entity_name varchar(58) NOT NULL
,   attribute_name varchar(61) NOT NULL
,   data_type varchar(30) NOT NULL
,   ordinal_position smallint NOT NULL
,   is_nullable boolean NOT NULL
,   is_subtype_attribute boolean NOT NULL
,   referenced_entity varchar(58) NULL
,   CONSTRAINT pk_base_entity_attribute PRIMARY KEY (entity_name, attribute_name)
,   CONSTRAINT fk_base_entity_attribute__schema FOREIGN KEY (schema_name) REFERENCES meta.schema(schema_name)
,   CONSTRAINT fk_base_entity_attribute__entity FOREIGN KEY (entity_name) REFERENCES meta.entity(entity_name)
,   CONSTRAINT fk_base_entity_attribute__referenced_entity FOREIGN KEY (referenced_entity) REFERENCES meta.entity(entity_name)
,   CONSTRAINT chk_base_entity_attribute_name_length CHECK ((char_length(entity_name) + char_length(attribute_name)) <= 62)
);

CREATE UNIQUE INDEX ux_base_entity_attribute__ordinal_position_over_entity ON meta.base_entity_attribute(entity_name, ordinal_position);