#!/usr/bin/python

import argparse
import os
import subprocess

def check_cmd_call(sp_child):
    data = sp_child.communicate()[0]
    rc = sp_child.returncode
    if rc is not 0:
        print('Error! Exiting with status: {}'.format(rc))
        exit(rc)

def run_sql_cmd(sql, args, database):
    env = os.environ.copy()
    env['PGHOST'] = args.host
    env['PGPORT'] = args.port
    env['PGUSER'] = args.username
    env['PGPASSWORD'] = args.password
    env['PGDATABASE'] = database
    cmd = 'psql --command "{}"'.format(sql)
    check_cmd_call(subprocess.Popen(cmd, shell=True, env=env))

def run_sql_file(file, args, variables, database):
    env = os.environ.copy()
    env['PGHOST'] = args.host
    env['PGPORT'] = args.port
    env['PGUSER'] = args.username
    env['PGPASSWORD'] = args.password
    env['PGDATABASE'] = database
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

def generate(args):
    drop_database(args)
    create_database(args)

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