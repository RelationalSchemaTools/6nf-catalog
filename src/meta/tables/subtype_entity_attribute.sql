CREATE TABLE meta.subtype_entity_attribute (
    base_entity_name varchar(58) NOT NULL
,   subtype_entity_name varchar(58) NOT NULL
,   attribute_name varchar(61) NOT NULL
,   nullable boolean NOT NULL
,   CONSTRAINT pk_subtype_entity_attribute PRIMARY KEY (base_entity_name, subtype_entity_name, attribute_name)
,   CONSTRAINT fk_subtype_entity_attribute__subtype_entity FOREIGN KEY (subtype_entity_name) REFERENCES meta.entity(entity_name)
,   CONSTRAINT fk_subtype_entity_attribute__base_entity_attribute FOREIGN KEY (base_entity_name, attribute_name) REFERENCES meta.base_entity_attribute(entity_name, attribute_name)
);