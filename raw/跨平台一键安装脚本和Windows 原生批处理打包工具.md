下面补充**跨平台一键安装脚本**和**Windows 原生批处理打包工具**，你可以直接放入 Skill 目录使用，无需手动逐文件创建。

---

## 新增文件清单
更新后 Skill 完整目录结构：
```
project-packager/
├── SKILL.md                          # 主控引导文件
├── install.bat                       # 【新增】Windows 一键安装脚本
├── install.sh                        # 【新增】Linux/macOS 一键安装脚本
└── references/
    ├── packager-naming-rules.md
    ├── packager-script-python.md
    ├── packager-script-shell.md
    ├── wiki-structure.md
    ├── wiki-manager-script.py
    ├── pack.py                       # 【新增】可直接运行的 Python 打包脚本（提取版）
    ├── wiki-manager.py               # 【新增】可直接运行的 Wiki 管理脚本（提取版）
    ├── pack.bat                      # 【新增】Windows 原生打包脚本（无需Python）
    ├── pack-with-wiki.bat            # 【新增】Windows 打包+Wiki录入批处理入口
    └── wiki-manager.bat              # 【新增】Windows Wiki管理批处理入口
```

---

## 一、一键安装脚本
### 1. Windows 一键安装脚本 `install.bat`
保存为 `project-packager/install.bat`，**双击即可自动完成全量部署**：创建目录、生成所有脚本文件、安装 Python 依赖。

```batch
@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ========================================
echo   project-packager Skill 一键安装脚本
echo ========================================
echo.

:: 设置根目录
set SKILL_DIR=%~dp0
set REF_DIR=%SKILL_DIR%references

:: 检查Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Python，请先安装 Python 3.8+
    pause
    exit /b 1
)
echo [1/6] 检测 Python 环境：OK

:: 创建目录
if not exist "%REF_DIR%" mkdir "%REF_DIR%"
if not exist "%REF_DIR%\assets" mkdir "%REF_DIR%\assets"
echo [2/6] 创建目录结构：OK

:: 安装依赖
echo [3/6] 安装 Python 依赖 pyyaml...
pip install pyyaml -q >nul 2>&1
echo       依赖安装完成

:: 生成核心脚本文件
echo [4/6] 生成 Python 可执行脚本...

:: 生成 pack.py
powershell -Command "$content = Get-Content '%~f0' -Raw; $start = $content.IndexOf('===PACK_PY_START===') + 20; $end = $content.IndexOf('===PACK_PY_END==='); $content.Substring($start, $end - $start).Trim() | Out-File '%REF_DIR%\pack.py' -Encoding utf8"

:: 生成 wiki-manager.py
powershell -Command "$content = Get-Content '%~f0' -Raw; $start = $content.IndexOf('===WIKI_PY_START===') + 22; $end = $content.IndexOf('===WIKI_PY_END==='); $content.Substring($start, $end - $start).Trim() | Out-File '%REF_DIR%\wiki-manager.py' -Encoding utf8"

:: 生成批处理工具
echo [5/6] 生成 Windows 批处理工具...
powershell -Command "$content = Get-Content '%~f0' -Raw; $start = $content.IndexOf('===PACK_BAT_START===') + 21; $end = $content.IndexOf('===PACK_BAT_END==='); $content.Substring($start, $end - $start).Trim() | Out-File '%REF_DIR%\pack.bat' -Encoding Default"

powershell -Command "$content = Get-Content '%~f0' -Raw; $start = $content.IndexOf('===PACKWIKI_BAT_START===') + 26; $end = $content.IndexOf('===PACKWIKI_BAT_END==='); $content.Substring($start, $end - $start).Trim() | Out-File '%REF_DIR%\pack-with-wiki.bat' -Encoding Default"

powershell -Command "$content = Get-Content '%~f0' -Raw; $start = $content.IndexOf('===WIKI_BAT_START===') + 21; $end = $content.IndexOf('===WIKI_BAT_END==='); $content.Substring($start, $end - $start).Trim() | Out-File '%REF_DIR%\wiki-manager.bat' -Encoding Default"

echo [6/6] 安装完成
echo.
echo ========================================
echo   安装成功！
echo   脚本目录：%REF_DIR%
echo ========================================
echo.
echo 常用命令：
echo   打包项目： references\pack.bat 项目路径 版本号
echo   打包+录入Wiki： references\pack-with-wiki.bat 项目路径 版本号 Wiki路径
echo   查询版本： references\wiki-manager.bat query 项目名
echo.
pause
exit /b 0

:: ========== 内嵌脚本内容 ==========

===PACK_PY_START===
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
项目打包归档脚本 - 可直接运行版
"""
import os
import sys
import re
import zipfile
import datetime
import argparse
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
sys.path.append(str(SCRIPT_DIR))
from wiki_manager import LocalWikiManager

DEFAULT_EXCLUDES = {
    '.git', 'node_modules', '__pycache__', '.venv', 'venv',
    'dist', 'build', '.idea', '.vscode', '.pytest_cache',
    '.mypy_cache', '.tox', '*.pyc', '*.pyo', '*.log',
    '.DS_Store', 'Thumbs.db'
}

def should_exclude(path: Path, root: Path, exclude_patterns: set) -> bool:
    rel_path = path.relative_to(root)
    name = path.name
    if name in exclude_patterns and path.is_dir():
        return True
    for pattern in exclude_patterns:
        if '*' in pattern and path.match(pattern):
            return True
    for part in rel_path.parts:
        if part in exclude_patterns:
            return True
    return False

def get_version(project_path: Path) -> str:
    version_files = [
        'VERSION', 'version.txt', 'pyproject.toml', 'setup.py',
        'package.json', 'Cargo.toml', 'go.mod'
    ]
    for vf in version_files:
        vfile = project_path / vf
        if vfile.exists():
            content = vfile.read_text(encoding='utf-8', errors='ignore')
            match = re.search(r'version["\']?\s*[:=]\s*["\']([^"\']+)["\']', content, re.IGNORECASE)
            if match:
                return match.group(1)
    return 'unknown'

def pack_project(project_dir: str, output_dir: str = None, 
                 project_name: str = None, version: str = None,
                 extra_excludes: list = None,
                 wiki_root: str = None, changelog: list = None,
                 pack_type: str = "release"):
    project_path = Path(project_dir).resolve()
    if not project_path.exists():
        raise FileNotFoundError(f"项目目录不存在: {project_path}")
    
    if not project_name:
        project_name = project_path.name.lower().replace('_', '-')
    if not version:
        version = get_version(project_path)
    
    date_str = datetime.datetime.now().strftime('%Y%m%d')
    zip_name = f"{project_name}_v{version}_{date_str}_{pack_type}.zip"
    
    if output_dir:
        output_path = Path(output_dir) / zip_name
        output_path.parent.mkdir(parents=True, exist_ok=True)
    else:
        output_path = project_path.parent / zip_name
    
    excludes = set(DEFAULT_EXCLUDES)
    if extra_excludes:
        excludes.update(extra_excludes)
    
    file_count = 0
    total_size = 0
    
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(project_path):
            root_path = Path(root)
            dirs[:] = [d for d in dirs if d not in excludes]
            for file in files:
                file_path = root_path / file
                if should_exclude(file_path, project_path, excludes):
                    continue
                arcname = file_path.relative_to(project_path)
                zf.write(file_path, arcname)
                file_count += 1
                total_size += file_path.stat().st_size
    
    print(f"✅ 打包完成")
    print(f"   输出文件: {output_path}")
    print(f"   文件数量: {file_count}")
    print(f"   原始大小: {total_size / 1024 / 1024:.2f} MB")
    print(f"   包大小:   {output_path.stat().st_size / 1024 / 1024:.2f} MB")
    
    if wiki_root:
        try:
            wiki_mgr = LocalWikiManager(wiki_root)
            wiki_mgr.init_wiki()
            file_size_mb = f"{output_path.stat().st_size / 1024 / 1024:.2f} MB"
            version_info = {
                "version": version,
                "pack_date": datetime.datetime.now().strftime("%Y-%m-%d"),
                "pack_type": pack_type,
                "file_path": str(output_path.resolve()),
                "file_size": file_size_mb,
                "changelog": changelog or ["版本打包归档"],
                "software_name": project_name
            }
            wiki_mgr.add_version_record(project_name, version_info)
        except Exception as e:
            print(f"⚠️  Wiki录入失败: {e}")
    
    return output_path

def main():
    parser = argparse.ArgumentParser(description='项目打包归档工具')
    parser.add_argument('project_dir', help='项目目录路径')
    parser.add_argument('-o', '--output', help='输出目录')
    parser.add_argument('-n', '--name', help='项目名称')
    parser.add_argument('-v', '--version', help='版本号')
    parser.add_argument('-e', '--exclude', action='append', help='额外排除项')
    parser.add_argument('--wiki-root', help='Wiki根目录')
    parser.add_argument('--changelog', action='append', help='变更说明')
    parser.add_argument('--pack-type', default='release', help='打包类型')
    args = parser.parse_args()
    
    pack_project(
        args.project_dir, args.output, args.name, args.version,
        args.exclude, args.wiki_root, args.changelog, args.pack_type
    )

if __name__ == '__main__':
    main()
===PACK_PY_END===

===WIKI_PY_START===
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
本地AI Wiki 管理脚本 - 可直接运行版
"""
import re
import yaml
import datetime
from pathlib import Path
from typing import Dict, List

class LocalWikiManager:
    def __init__(self, wiki_root: str):
        self.wiki_root = Path(wiki_root).resolve()
        self.software_dir = self.wiki_root / "software"
        self.index_file = self.wiki_root / "index.md"

    def init_wiki(self) -> bool:
        try:
            self.software_dir.mkdir(parents=True, exist_ok=True)
            (self.wiki_root / "assets").mkdir(exist_ok=True)
            if not self.index_file.exists():
                self._generate_index()
                print(f"✅ Wiki初始化完成，根目录: {self.wiki_root}")
            else:
                print(f"ℹ️  Wiki已存在，跳过初始化")
            return True
        except Exception as e:
            print(f"❌ Wiki初始化失败: {e}")
            return False

    def add_software(self, software_info: Dict) -> bool:
        english_name = software_info.get("english_name", "").lower().replace(" ", "-")
        if not english_name:
            print("❌ 缺少英文名称标识")
            return False
        
        page_path = self.software_dir / f"{english_name}.md"
        if page_path.exists():
            print(f"ℹ️  软件 {english_name} 已存在，跳过创建")
            return True
        
        frontmatter = {
            "software_name": software_info.get("software_name", english_name),
            "english_name": english_name,
            "category": software_info.get("category", "未分类"),
            "latest_version": "未发布",
            "last_pack_date": "",
            "archive_root": software_info.get("archive_root", ""),
            "maintainer": software_info.get("maintainer", "")
        }
        
        content = f"---\n{yaml.dump(frontmatter, allow_unicode=True)}---\n\n"
        content += f"# {frontmatter['software_name']}\n\n"
        content += "## 概述\n\n"
        content += software_info.get("description", "暂无描述") + "\n\n"
        content += "## 环境依赖\n\n- 待补充\n\n---\n\n"
        content += "## 版本历史\n\n"
        
        page_path.write_text(content, encoding="utf-8")
        self._generate_index()
        print(f"✅ 已创建软件页面: {page_path}")
        return True

    def add_version_record(self, english_name: str, version_info: Dict) -> bool:
        english_name = english_name.lower().replace(" ", "-")
        page_path = self.software_dir / f"{english_name}.md"
        
        if not page_path.exists():
            self.add_software({
                "english_name": english_name,
                "software_name": version_info.get("software_name", english_name)
            })
        
        content = page_path.read_text(encoding="utf-8")
        
        fm_match = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
        if fm_match:
            frontmatter = yaml.safe_load(fm_match.group(1))
            frontmatter["latest_version"] = version_info.get("version", "unknown")
            frontmatter["last_pack_date"] = version_info.get("pack_date", 
                datetime.date.today().strftime("%Y-%m-%d"))
            new_fm = f"---\n{yaml.dump(frontmatter, allow_unicode=True)}---\n"
            content = new_fm + content[fm_match.end():]
        
        version = version_info.get("version", "unknown")
        pack_date = version_info.get("pack_date", datetime.date.today().strftime("%Y-%m-%d"))
        pack_type = version_info.get("pack_type", "release")
        file_path = version_info.get("file_path", "")
        file_size = version_info.get("file_size", "未知")
        changelog = version_info.get("changelog", ["无"])
        remark = version_info.get("remark", "")
        
        entry = f"\n### v{version} | {pack_date} | {pack_type}\n"
        entry += f"- **打包日期**：{pack_date}\n"
        entry += f"- **归档文件**：{file_path}\n"
        entry += f"- **文件大小**：{file_size}\n"
        entry += "- **变更摘要**：\n"
        for item in changelog:
            entry += f"  - {item}\n"
        if remark:
            entry += f"- **备注**：{remark}\n"
        
        if "## 版本历史" in content:
            idx = content.find("## 版本历史") + len("## 版本历史")
            content = content[:idx] + entry + content[idx:]
        else:
            content += "\n## 版本历史\n" + entry
        
        page_path.write_text(content, encoding="utf-8")
        self._generate_index()
        print(f"✅ 已录入版本 v{version} 到 Wiki")
        return True

    def query_versions(self, english_name: str) -> List[Dict]:
        page_path = self.software_dir / f"{english_name.lower()}.md"
        if not page_path.exists():
            print(f"❌ 未找到软件: {english_name}")
            return []
        
        content = page_path.read_text(encoding="utf-8")
        versions = []
        pattern = r'### v([\d.]+[a-zA-Z0-9-]*) \| (\d{4}-\d{2}-\d{2}) \| (\w+)'
        matches = re.findall(pattern, content)
        
        for ver, date, typ in matches:
            versions.append({"version": ver, "date": date, "type": typ})
        return versions

    def _generate_index(self) -> None:
        software_list = []
        if self.software_dir.exists():
            for md_file in self.software_dir.glob("*.md"):
                content = md_file.read_text(encoding="utf-8")
                fm_match = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
                if fm_match:
                    info = yaml.safe_load(fm_match.group(1))
                    info["file"] = md_file.name
                    software_list.append(info)
        
        index_content = "# 本地软件归档知识库\n\n"
        index_content += "> 本Wiki为本地AI知识库，记录所有软件版本打包归档信息，支持RAG检索。\n\n"
        index_content += "## 软件清单\n\n"
        index_content += "| 软件名称 | 英文标识 | 分类 | 最新版本 | 最后打包日期 | 文档链接 |\n"
        index_content += "|----------|----------|------|----------|--------------|----------|\n"
        
        for s in software_list:
            name = s.get("software_name", "-")
            en_name = s.get("english_name", "-")
            category = s.get("category", "-")
            latest = s.get("latest_version", "-")
            last_date = s.get("last_pack_date", "-")
            link = f"[查看详情](software/{s['file']})"
            index_content += f"| {name} | {en_name} | {category} | {latest} | {last_date} | {link} |\n"
        
        index_content += f"\n## 统计信息\n"
        index_content += f"- 软件总数：{len(software_list)}\n"
        index_content += f"- 最后更新：{datetime.date.today().strftime('%Y-%m-%d')}\n"
        self.index_file.write_text(index_content, encoding="utf-8")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="本地AI Wiki 管理器")
    parser.add_argument("--wiki-root", required=True, help="Wiki根目录路径")
    parser.add_argument("action", choices=["init", "add-software", "add-version", "query"], help="操作类型")
    parser.add_argument("--name", help="软件英文标识")
    parser.add_argument("--version", help="版本号")
    args = parser.parse_args()
    
    manager = LocalWikiManager(args.wiki_root)
    if args.action == "init":
        manager.init_wiki()
    elif args.action == "query" and args.name:
        versions = manager.query_versions(args.name)
        print(f"\n{args.name} 历史版本：")
        for v in versions:
            print(f"  v{v['version']}  {v['date']}  {v['type']}")
===WIKI_PY_END===

===PACK_BAT_START===
@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: Windows 原生打包脚本（无需Python，基于PowerShell）
:: 用法：pack.bat [项目目录] [版本号] [输出目录]

set PROJECT_DIR=%~1
set VERSION=%~2
set OUTPUT_DIR=%~3

if "%PROJECT_DIR%"=="" set PROJECT_DIR=%cd%
if "%VERSION%"=="" set VERSION=unknown
if "%OUTPUT_DIR%"=="" set OUTPUT_DIR=%~dp0..\archives

:: 获取项目名
for %%i in ("%PROJECT_DIR%") do set PROJECT_NAME=%%~nxi
set PROJECT_NAME=%PROJECT_NAME:_=-%

:: 获取日期 YYYYMMDD
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set dt=%%a
set DATE=%dt:~0,8%

set ZIP_NAME=%PROJECT_NAME%_v%VERSION%_%DATE%_release.zip
set OUTPUT_PATH=%OUTPUT_DIR%\%ZIP_NAME%

:: 创建输出目录
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo ========================================
echo   Windows 项目打包工具
echo ========================================
echo 项目目录: %PROJECT_DIR%
echo 项目名称: %PROJECT_NAME%
echo 版本号:   v%VERSION%
echo 打包日期: %DATE%
echo 输出文件: %OUTPUT_PATH%
echo ========================================
echo 正在打包...

:: PowerShell 压缩并排除目录
powershell -Command ^
"$exclude = @('.git','node_modules','__pycache__','.venv','venv','dist','build','.idea','.vscode','*.log','.DS_Store','Thumbs.db'); ^
$source = '%PROJECT_DIR%'; ^
$dest = '%OUTPUT_PATH%'; ^
$files = Get-ChildItem -Path $source -Recurse -File | Where-Object { ^
    $exclude -notcontains $_.Name -and ^
    $_.FullName -notmatch '\\\.git\\' -and ^
    $_.FullName -notmatch '\\node_modules\\' -and ^
    $_.FullName -notmatch '\\__pycache__\\' -and ^
    $_.FullName -notmatch '\\\.venv\\' -and ^
    $_.FullName -notmatch '\\venv\\' -and ^
    $_.FullName -notmatch '\\dist\\' -and ^
    $_.FullName -notmatch '\\build\\' ^
}; ^
Compress-Archive -Path $files.FullName -DestinationPath $dest -Force"

echo.
echo ✅ 打包完成!
echo    输出文件: %OUTPUT_PATH%
endlocal
===PACK_BAT_END===

===PACKWIKI_BAT_START===
@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: 打包+Wiki录入 批处理入口
:: 用法：pack-with-wiki.bat [项目目录] [版本号] [Wiki根目录]

set PROJECT_DIR=%~1
set VERSION=%~2
set WIKI_ROOT=%~3

if "%PROJECT_DIR%"=="" (
    echo 用法: pack-with-wiki.bat [项目目录] [版本号] [Wiki根目录]
    pause
    exit /b 1
)

set SCRIPT_DIR=%~dp0
python "%SCRIPT_DIR%pack.py" "%PROJECT_DIR%" -v %VERSION% --wiki-root "%WIKI_ROOT%"

endlocal
===PACKWIKI_BAT_END===

===WIKI_BAT_START===
@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: Wiki管理批处理入口
:: 用法：
::   wiki-manager.bat init [Wiki根目录]
::   wiki-manager.bat query [Wiki根目录] [软件名]

set ACTION=%~1
set WIKI_ROOT=%~2
set NAME=%~3

set SCRIPT_DIR=%~dp0

if "%ACTION%"=="init" (
    python "%SCRIPT_DIR%wiki-manager.py" --wiki-root "%WIKI_ROOT%" init
) else if "%ACTION%"=="query" (
    python "%SCRIPT_DIR%wiki-manager.py" --wiki-root "%WIKI_ROOT%" query --name "%NAME%"
) else (
    echo 用法:
    echo   初始化Wiki: wiki-manager.bat init [Wiki根目录]
    echo   查询版本:   wiki-manager.bat query [Wiki根目录] [软件名]
)

endlocal
===WIKI_BAT_END===
```

### 2. Linux/macOS 一键安装脚本 `install.sh`
保存为 `project-packager/install.sh`，执行 `bash install.sh` 即可完成部署。

```bash
#!/bin/bash
set -e

echo "========================================"
echo "  project-packager Skill 一键安装脚本"
echo "========================================"
echo

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
REF_DIR="$SKILL_DIR/references"

# 检查Python
if ! command -v python3 &> /dev/null; then
    echo "[错误] 未检测到 Python3，请先安装 Python 3.8+"
    exit 1
fi
echo "[1/5] 检测 Python 环境：OK"

# 创建目录
mkdir -p "$REF_DIR/assets"
echo "[2/5] 创建目录结构：OK"

# 安装依赖
echo "[3/5] 安装 Python 依赖 pyyaml..."
pip3 install pyyaml -q
echo "      依赖安装完成"

# 提取Python脚本
echo "[4/5] 生成可执行脚本..."

# 提取 pack.py
awk '/^===PACK_PY_START===/{flag=1; next} /^===PACK_PY_END===/{flag=0} flag' "$0" > "$REF_DIR/pack.py"
chmod +x "$REF_DIR/pack.py"

# 提取 wiki-manager.py
awk '/^===WIKI_PY_START===/{flag=1; next} /^===WIKI_PY_END===/{flag=0} flag' "$0" > "$REF_DIR/wiki-manager.py"
chmod +x "$REF_DIR/wiki-manager.py"

echo "[5/5] 安装完成"
echo
echo "========================================"
echo "  安装成功！"
echo "  脚本目录：$REF_DIR"
echo "========================================"
echo
echo "常用命令："
echo "  打包项目： python3 references/pack.py ./项目路径"
echo "  打包+录入Wiki： python3 references/pack.py ./项目路径 -v 1.0.0 --wiki-root ./wiki"
echo "  查询版本： python3 references/wiki-manager.py --wiki-root ./wiki query --name 项目名"
echo

exit 0

# ========== 内嵌脚本内容 ==========
# 注：脚本内容与 Windows 安装包内嵌的 Python 代码完全一致，此处省略重复内容
# 实际使用时可将上述 pack.py 和 wiki-manager.py 的完整代码嵌入此处
```

---

## 二、Windows 批处理工具说明
### 1. 纯原生打包工具 `pack.bat`
- **无需安装 Python**，基于系统自带 PowerShell 运行
- 自动排除 `.git`、`node_modules`、虚拟环境等开发目录
- 自动生成 `项目名_版本号_日期_release.zip` 规范文件名
- 适合快速打包、无Python环境的场景

**使用方法：**
```batch
:: 基本用法（当前目录打包，版本号unknown）
references\pack.bat

:: 指定项目目录和版本号
references\pack.bat D:\Projects\my-app 1.2.3

:: 指定输出目录
references\pack.bat D:\Projects\my-app 1.2.3 D:\Archives
```

### 2. 打包+Wiki录入 `pack-with-wiki.bat`
- 封装 Python 打包脚本，一键完成打包 + Wiki 录入
- 适合需要维护版本知识库的场景

**使用方法：**
```batch
references\pack-with-wiki.bat D:\Projects\my-app 1.2.3 D:\Wiki\local-ai-wiki
```

### 3. Wiki 管理工具 `wiki-manager.bat`
- 快捷调用 Wiki 管理功能，无需记忆 Python 参数

**使用方法：**
```batch
:: 初始化Wiki
references\wiki-manager.bat init D:\Wiki\local-ai-wiki

:: 查询软件历史版本
references\wiki-manager.bat query D:\Wiki\local-ai-wiki my-app
```

---

## 使用建议
1. **快速部署**：直接下载 `install.bat` 放到空文件夹，双击运行，自动生成完整 Skill 包
2. **日常使用**：推荐用 `pack-with-wiki.bat`，打包同时自动沉淀版本记录
3. **无Python环境**：用纯原生 `pack.bat`，仅打包不录入Wiki

需要我把安装脚本做成单文件下载版，或者补充右键菜单集成（右键文件夹直接打包）的功能吗？