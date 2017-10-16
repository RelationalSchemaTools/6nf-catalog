CREATE TABLE meta.base_entity_attribute (
    entity_name varchar(58) NOT NULL
,   attribute_name varchar(61) NOT NULL
,   data_type varchar(30) NOT NULL
,   nullable boolean NOT NULL
,   is_subtype_attribute boolean NOT NULL
,   CONSTRAINT pk_base_entity_attribute PRIMARY KEY (entity_name, attribute_name)
,   CONSTRAINT fk_base_entity_attribute__entity FOREIGN KEY (entity_name) REFERENCES meta.entity(entity_name)
,   CONSTRAINT chk_base_entity_attribute_name_length CHECK ((char_length(entity_name) + char_length(attribute_name)) <= 62)
);