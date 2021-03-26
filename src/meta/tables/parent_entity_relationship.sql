CREATE TABLE meta.parent_entity_relationship (
    parent_entity_name varchar(58) NOT NULL
,   child_entity_name varchar(58) NOT NULL
,   CONSTRAINT pk_parent_entity_relationship PRIMARY KEY (parent_entity_name, child_entity_name)
,   CONSTRAINT fk_parent_entity_relationship__parent_entity FOREIGN KEY (parent_entity_name) REFERENCES meta.entity(entity_name)
,   CONSTRAINT fk_parent_entity_relationship__child_entity FOREIGN KEY (child_entity_name) REFERENCES meta.entity(entity_name)
);