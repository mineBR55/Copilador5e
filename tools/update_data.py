#!/usr/bin/env python3
from __future__ import annotations
import argparse, shutil, socket, subprocess, sys, tempfile, urllib.error, urllib.request, zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
URLS=[
 'https://github.com/5etools-mirror-3/5etools-src/archive/refs/heads/main.zip',
 'https://codeload.github.com/5etools-mirror-3/5etools-src/zip/refs/heads/main',
]
def import_data(data_dir:Path):
 if not (data_dir/'spells').exists(): raise RuntimeError(f'Pasta data invalida: {data_dir}')
 subprocess.run([sys.executable,str(ROOT/'tools'/'import_5etools.py'),'--source',str(data_dir),'--output',str(ROOT/'data')],check=True)
def download(url,dest):
 req=urllib.request.Request(url,headers={'User-Agent':'Compendium5e-Updater/0.9.2'})
 with urllib.request.urlopen(req,timeout=45) as src, dest.open('wb') as out: shutil.copyfileobj(src,out)
def main():
 ap=argparse.ArgumentParser(); ap.add_argument('--local',type=Path,help='Pasta data local; nao usa internet'); a=ap.parse_args()
 print('Compendium5e: atualizador de dados')
 if a.local:
  print(f'Usando fonte local: {a.local}'); import_data(a.local.resolve()); print('Dados atualizados a partir da fonte local.'); return
 errors=[]
 with tempfile.TemporaryDirectory(prefix='compendium5e_') as td:
  td=Path(td); z=td/'5etools.zip'
  for url in URLS:
   try:
    print(f'Tentando baixar: {url}')
    download(url,z); break
   except (urllib.error.URLError,TimeoutError,socket.gaierror,OSError) as ex:
    errors.append(f'{url}: {ex}'); print(f'Falhou: {ex}')
  else:
   print('\nNao foi possivel resolver/acessar os enderecos de download.')
   print('Os dados atuais foram preservados; nada foi apagado.')
   print('Alternativa offline: atualizar_dados.bat "C:\\caminho\\para\\5etools\\data"')
   raise RuntimeError(' | '.join(errors))
  print('Extraindo...')
  try:
   with zipfile.ZipFile(z) as f: f.extractall(td/'src')
  except zipfile.BadZipFile as ex: raise RuntimeError('O download nao e um ZIP valido; proxy/firewall pode ter retornado outra pagina.') from ex
  roots=list((td/'src').glob('*/data'))
  if not roots: raise RuntimeError('Nao foi encontrada a pasta data na distribuicao baixada.')
  print('Convertendo dados para Lua...'); import_data(roots[0])
 print('Dados atualizados. Execute rdk c ou rdk i.')
if __name__=='__main__':
 try: main()
 except Exception as e: print('ERRO:',e); sys.exit(1)
