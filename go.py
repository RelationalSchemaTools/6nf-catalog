#!/usr/bin/python

import argparse
import os
import subprocess
import json

MISSING = object()

def check_cmd_call(sp_child):
    data = sp_child.communicate()[0]
    rc = sp_child.returncode
    if rc is not 0:
        print('Error! Exiting with status: {}'.format(rc))
        exit(rc)

def run_sql_cmd(sql, args, database=MISSING):
    if database is MISSING:
        database = args.database

    env = os.environ.copy()
    env['PGHOST'] = args.host
    env['PGPORT'] = args.port
    env['PGUSER'] = args.username
    env['PGPASSWORD'] = args.password
    env['PGDATABASE'] = database
    env['PAGER'] = ''
    cmd = 'psql --command "{}"'.format(sql)
    check_cmd_call(subprocess.Popen(cmd, shell=True, env=env))

def run_sql_file(file, args, variables={}, database=MISSING):
    if database is MISSING:
        database = args.database

    env = os.environ.copy()
    env['PGHOST'] = args.host
    env['PGPORT'] = args.port
    env['PGUSER'] = args.username
    env['PGPASSWORD'] = args.password
    env['PGDATABASE'] = database
    env['PAGER'] = ''

    psql_variables = ' '.join(['--set "%s=%s"' % (key, value) for (key, value) in variables.items()])

    cmd = 'psql --file "{0}" {1}'.format(file, psql_variables)
    check_cmd_call(subprocess.Popen(cmd, shell=True, env=env))

def drop_database(args):
    print('Dropping {}'.format(args.database))
    variables = {
        'database': args.database
    }
    run_sql_file('scripts/drop_database.sql', args, variables, 'postgres')

def create_database(args):
    print('Creating {}'.format(args.database))
    variables = {
        'database': args.database
    }
    run_sql_file('scripts/create_database.sql', args, variables, 'postgres')

def create_meta_schema(args):
    print('Creating meta schema')
    files = [
        'src/meta/meta.sql',
        'src/meta/tables/catalog_metadata.sql',
        'src/meta/tables/entity_type.sql',
        'src/meta/tables/entity.sql',
        'src/meta/tables/base_entity_attribute.sql',
        'src/meta/tables/subtype_entity_attribute.sql',
        'src/meta/tables/parent_entity_relationship.sql',
        'src/meta/tables/referenced_entity_relationship.sql'
    ]
    for file in files:
        run_sql_file(file, args)

def generate(args):
    drop_database(args)
    create_database(args)
    create_meta_schema(args)
    with open('catalog_metadata.json') as catalog_metadata:
        parsed_json = json.load(catalog_metadata)
        # PostgreSQL JSONB does not preserve ordering, so ordinal position must be set here
        for entity in parsed_json['entities']:
            index = 0
            if 'attributes' in entity:
                for attribute in entity['attributes']:
                    attribute['ordinal_position'] = index
                    index += 1
            if 'subtype_attributes' in entity:
                for attribute in entity['subtype_attributes']:
                    attribute['ordinal_position'] = index
                    index += 1
        sql = 'INSERT INTO meta.catalog_metadata SELECT (\'{}\'::jsonb)'.format(json.dumps(parsed_json)).replace('"', '\\"')
        run_sql_cmd(sql, args)

    run_sql_file('src/meta/scripts/catalog_metadata.sql', args)

def main():
    parser = argparse.ArgumentParser(description='Facilitate creating robust sixth normal form (6NF) databases with a schema generator')

    subparsers = parser.add_subparsers()

    parser_generate = subparsers.add_parser('generate')
    parser_generate.set_defaults(func=generate)
    parser_generate.add_argument('--host', type=str, required=False, default='(local)', help='The target database host name or IP address')
    parser_generate.add_argument('--port', type=str, required=False, default='5432', help='The target database port')
    parser_generate.add_argument('--username', type=str, required=False, default='postgres', help='The target database user')
    parser_generate.add_argument('--password', type=str, required=False, default='postgres', help='The target database user\'s password')
    parser_generate.add_argument('--database', type=str, required=False, default='generated_schema', help='The target database name')

    args = parser.parse_args()

    args.func(args)

if __name__ == '__main__':
    main()