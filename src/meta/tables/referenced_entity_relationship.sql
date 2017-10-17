CREATE TABLE meta.referenced_entity_relationship (
    referencing_entity_name varchar(58) NOT NULL
,   referenced_entity_name varchar(58) NOT NULL
,   referencing_entity_attribute_name varchar(61) NOT NULL
,   CONSTRAINT pk_referenced_entity_relationship PRIMARY KEY (referencing_entity_name, referenced_entity_name)
,   CONSTRAINT fk_referenced_entity_relationship__referencing_entity FOREIGN KEY (referencing_entity_name) REFERENCES meta.entity(entity_name)
,   CONSTRAINT fk_referenced_entity_relationship__referenced_entity FOREIGN KEY (referenced_entity_name) REFERENCES meta.entity(entity_name)
,   CONSTRAINT fk_referenced_entity_relationship__entity_attribute FOREIGN KEY (referencing_entity_name, referencing_entity_attribute_name) REFERENCES meta.base_entity_attribute(entity_name, attribute_name)
);