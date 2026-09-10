# 项目打包归档 + 本地AI Wiki 增强版 Skill
在原有打包归档能力基础上，新增**本地AI Wiki创建、版本信息自动录入、历史记录检索维护**能力，打包完成后自动将版本信息结构化写入本地Markdown知识库，可直接供本地大模型RAG检索使用。

---

## 更新后 Skill 文件结构
```
project-packager/
├── SKILL.md                          # 主控引导文件（新增Wiki全能力）
└── references/
    ├── packager-script-python.md     # Python打包脚本（集成Wiki自动录入）
    ├── packager-script-shell.md      # Shell打包脚本
    ├── packager-naming-rules.md      # 打包命名与排除规范
    ├── wiki-structure.md             # 本地AI Wiki 目录结构与页面模板
    └── wiki-manager-script.py        # Wiki管理核心脚本（增删改查全能力）
```

---

## 一、SKILL.md（主控文件，全量更新）
```markdown
---
name: project-packager
description: 将项目文件夹打包归档，自动生成含版本号与日期的压缩包；支持创建与维护本地AI Wiki知识库，自动录入打包版本信息，构建可检索的软件版本归档库。
---

# 项目打包归档与本地AI Wiki Skill

## 概述
本Skill用于软件版本发布、归档备份与知识库管理场景。核心能力包含两部分：
1. 智能打包归档：自动识别项目版本，按规范命名生成压缩包，排除开发依赖文件
2. 本地AI Wiki维护：创建结构化本地Markdown知识库，打包后自动录入版本信息，支持历史版本查询、索引维护，可直接对接本地大模型RAG检索

## 使用场景
使用本 Skill 当用户请求满足任一条件：
- 需要将项目/软件打包成压缩包发布或归档
- 要求文件名包含版本号、生成日期等标识信息
- 需要将打包版本信息录入本地AI Wiki，构建可检索的版本知识库
- 需要初始化、创建、维护本地项目AI Wiki知识库
- 需要查询软件历史打包记录、版本变更、归档文件位置
- 需要管理多软件、多版本的归档信息，供本地大模型RAG调用

不要使用本 Skill 当：
- 只是单纯的文件压缩解压操作咨询
- 用户仅询问压缩命令语法
- 与项目版本归档、Wiki知识库无关的普通压缩需求

## 核心流程
### 流程A：项目打包 + 自动录入Wiki
1. 确认打包参数：项目路径、版本号、输出格式、排除规则、Wiki路径
2. 读取命名规范：遵循 `packager-naming-rules.md` 命名约定
3. 执行打包逻辑：调用Python/Shell脚本生成压缩包
4. 读取Wiki规范：遵循 `wiki-structure.md` 结构与模板
5. 自动录入Wiki：调用Wiki管理器，将本次打包信息写入对应软件页面
6. 更新Wiki索引：同步更新总索引页，保证知识库结构完整
7. 输出执行结果：返回打包文件路径 + Wiki录入结果

### 流程B：本地AI Wiki 独立维护
1. 确认操作类型：初始化Wiki / 新增软件条目 / 录入版本记录 / 查询历史版本 / 重建索引
2. 读取Wiki结构规范：遵循 `wiki-structure.md` 目录与模板要求
3. 调用Wiki管理脚本：执行对应增删改查操作
4. 返回操作结果与验证信息

## 打包命名规范
### 标准文件名格式
`{项目名}_{版本号}_{日期}_{类型标识}.{扩展名}`
- 项目名：全小写，单词间连字符分隔
- 版本号：语义化版本 `vX.Y.Z` 格式
- 日期：`YYYYMMDD` 格式，打包当日日期
- 类型标识：release / hotfix / snapshot
- 扩展名：zip / tar.gz / 7z

### 示例
- `my-app_v1.2.3_20260821_release.zip`
- `backend-service_v2.0.0-beta_20260821.tar.gz`

## 本地AI Wiki 规范
### 目录结构
```
wiki-root/
├── index.md                 # 全局索引页，所有软件清单与最新版本
├── software/                # 软件条目主目录
│   ├── my-app.md            # 单个软件的完整版本历史页
│   ├── backend-service.md
│   └── data-tool.md
└── assets/                  # 附件目录（可选，存放截图、文档等）
```

### 页面元数据规范
每个软件页面采用YAML Frontmatter存储结构化元数据，便于RAG检索：
```yaml
---
software_name: 我的应用
english_name: my-app
category: 前端应用
latest_version: v1.2.3
last_pack_date: 2026-08-21
archive_path: /path/to/archives
---
```

### 版本条目字段
每个版本记录包含：版本号、打包日期、文件路径、文件大小、变更摘要、环境依赖、备注。

## 默认排除列表
打包自动排除以下开发目录与文件：
- `.git/` 版本控制目录
- `node_modules/` Node依赖
- `__pycache__/` Python缓存
- `.venv/` `venv/` 虚拟环境
- `dist/` `build/` 构建产物
- `*.log` 日志文件
- `.DS_Store` 系统文件
- `.idea/` `.vscode/` IDE配置
```

---

## 二、references/wiki-structure.md（新增）
```markdown
# 本地AI Wiki 结构规范与页面模板

## 一、Wiki 目录结构
```
<wiki_root>/
├── index.md                 # 总索引页（自动生成）
├── software/                # 软件版本条目目录
│   ├── <软件英文名>.md      # 单个软件全版本历史
│   └── ...
└── assets/                  # 附件目录（可选）
```

### 目录说明
1. **index.md**：全局入口，自动维护所有软件清单、最新版本、最后打包时间，支持快速检索
2. **software/**：核心知识库目录，每个软件对应一个Markdown文件，存储全量版本历史
3. **assets/**：存放配套截图、部署文档、配置模板等附件

## 二、软件页面模板
每个软件对应一个 `.md` 文件，文件名使用英文小写连字符格式，与项目名一致。

### 完整页面模板
```markdown
---
software_name: 项目中文名称
english_name: project-name
category: 应用分类（如：后端服务/前端应用/工具脚本/数据平台）
latest_version: v1.0.0
last_pack_date: 2026-08-21
archive_root: /path/to/archives/
maintainer: 负责人
---

# 项目中文名称

## 概述
简要描述软件功能、适用场景、核心能力。

## 环境依赖
- 运行环境：Python 3.10+ / Node 18+ / JDK 17
- 依赖组件：MySQL 8.0 / Redis 7.0
- 部署方式：Docker / 二进制直接运行

---

## 版本历史

### v1.0.0 | 2026-08-21 | release
- **打包日期**：2026-08-21
- **归档文件**：/path/to/project-name_v1.0.0_20260821_release.zip
- **文件大小**：12.5 MB
- **变更摘要**：
  - 初始版本发布
  - 完成核心功能开发
  - 修复已知兼容性问题
- **备注**：首次正式发布版本
```

## 三、版本条目书写规范
1. **排序规则**：版本历史按时间倒序排列，最新版本在最上方
2. **标题格式**：`### 版本号 | 日期 | 类型标识`
3. **必填字段**：打包日期、归档文件路径、文件大小、变更摘要
4. **可选字段**：环境依赖变更、回滚说明、风险提示、打包人
5. **重复版本**：同一版本二次打包时，追加备注说明，不删除原记录

## 四、总索引页模板
```markdown
# 本地软件归档知识库

> 本Wiki为本地AI知识库，记录所有软件版本打包归档信息，支持RAG检索。

## 软件清单

| 软件名称 | 英文标识 | 分类 | 最新版本 | 最后打包日期 | 文档链接 |
|----------|----------|------|----------|--------------|----------|
| 我的应用 | my-app | 前端应用 | v1.2.3 | 2026-08-21 | [查看详情](software/my-app.md) |
| 后端服务 | backend-service | 后端服务 | v2.0.0 | 2026-08-15 | [查看详情](software/backend-service.md) |

## 统计信息
- 软件总数：2
- 版本总记录：5
- 最后更新：2026-08-21
```

## 五、RAG检索优化建议
1. 每个页面开头保留结构化YAML元数据，便于提取关键字段
2. 版本标题使用统一格式，便于语义匹配
3. 变更摘要使用清晰的条目化描述，避免大段无结构文本
4. 关键路径、版本号使用加粗标记，提升检索权重
```

---

## 三、references/wiki-manager-script.py（新增）
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
本地AI Wiki 管理脚本
支持：初始化Wiki、新增软件、录入版本记录、查询历史、重建索引
"""

import os
import re
import yaml
import datetime
from pathlib import Path
from typing import Dict, List, Optional


class LocalWikiManager:
    def __init__(self, wiki_root: str):
        self.wiki_root = Path(wiki_root).resolve()
        self.software_dir = self.wiki_root / "software"
        self.index_file = self.wiki_root / "index.md"

    def init_wiki(self) -> bool:
        """初始化Wiki目录结构"""
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
        """新增软件条目，创建对应页面"""
        english_name = software_info.get("english_name", "").lower().replace(" ", "-")
        if not english_name:
            print("❌ 缺少英文名称标识")
            return False
        
        page_path = self.software_dir / f"{english_name}.md"
        if page_path.exists():
            print(f"ℹ️  软件 {english_name} 已存在，跳过创建")
            return True
        
        # 构建页面内容
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
        """录入版本打包记录"""
        english_name = english_name.lower().replace(" ", "-")
        page_path = self.software_dir / f"{english_name}.md"
        
        if not page_path.exists():
            print(f"ℹ️  软件页面不存在，自动创建")
            self.add_software({
                "english_name": english_name,
                "software_name": version_info.get("software_name", english_name)
            })
        
        content = page_path.read_text(encoding="utf-8")
        
        # 提取并更新Frontmatter
        fm_match = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
        if fm_match:
            frontmatter = yaml.safe_load(fm_match.group(1))
            frontmatter["latest_version"] = version_info.get("version", "unknown")
            frontmatter["last_pack_date"] = version_info.get("pack_date", 
                datetime.date.today().strftime("%Y-%m-%d"))
            
            new_fm = f"---\n{yaml.dump(frontmatter, allow_unicode=True)}---\n"
            content = new_fm + content[fm_match.end():]
        
        # 构建版本条目
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
        
        # 插入到版本历史最上方
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
        """查询软件的所有历史版本"""
        page_path = self.software_dir / f"{english_name.lower()}.md"
        if not page_path.exists():
            print(f"❌ 未找到软件: {english_name}")
            return []
        
        content = page_path.read_text(encoding="utf-8")
        versions = []
        
        pattern = r'### v([\d.]+[a-zA-Z0-9-]*) \| (\d{4}-\d{2}-\d{2}) \| (\w+)'
        matches = re.findall(pattern, content)
        
        for ver, date, typ in matches:
            versions.append({
                "version": ver,
                "date": date,
                "type": typ
            })
        
        return versions

    def _generate_index(self) -> None:
        """自动生成总索引页"""
        software_list = []
        
        if self.software_dir.exists():
            for md_file in self.software_dir.glob("*.md"):
                content = md_file.read_text(encoding="utf-8")
                fm_match = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
                if fm_match:
                    info = yaml.safe_load(fm_match.group(1))
                    info["file"] = md_file.name
                    software_list.append(info)
        
        # 生成索引内容
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


# 命令行入口
if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="本地AI Wiki 管理器")
    parser.add_argument("--wiki-root", required=True, help="Wiki根目录路径")
    parser.add_argument("action", choices=["init", "add-software", "add-version", "query"], 
                        help="操作类型")
    parser.add_argument("--name", help="软件英文标识")
    parser.add_argument("--version", help="版本号")
    parser.add_argument("--file", help="归档文件路径")
    
    args = parser.parse_args()
    manager = LocalWikiManager(args.wiki_root)
    
    if args.action == "init":
        manager.init_wiki()
    elif args.action == "query" and args.name:
        versions = manager.query_versions(args.name)
        print(f"\n{args.name} 历史版本：")
        for v in versions:
            print(f"  v{v['version']}  {v['date']}  {v['type']}")
```

---

## 四、packager-script-python.md（集成Wiki能力更新）
在原有打包脚本基础上，新增Wiki录入参数，打包完成自动同步知识库。

### 核心更新点
1. 新增 `--wiki-root` 参数，指定本地Wiki根目录
2. 新增 `--changelog` 参数，支持传入变更摘要
3. 打包完成后自动调用 `LocalWikiManager` 录入版本信息
4. 自动初始化Wiki（若目录不存在）

### 脚本关键新增代码片段
```python
# 引入Wiki管理器
from wiki_manager_script import LocalWikiManager

def pack_project(project_dir: str, output_dir: str = None, 
                 project_name: str = None, version: str = None,
                 extra_excludes: list = None,
                 wiki_root: str = None, changelog: list = None,
                 pack_type: str = "release"):
    # ... 原有打包逻辑不变 ...
    
    output_path = project_path.parent / zip_name
    
    # ... 打包执行逻辑 ...
    
    # ===== 新增：自动录入Wiki =====
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
    # =============================
    
    return output_path

# 命令行参数新增
parser.add_argument('--wiki-root', help='本地AI Wiki根目录，指定后自动录入版本信息')
parser.add_argument('--changelog', action='append', help='版本变更说明，可多次添加')
parser.add_argument('--pack-type', default='release', 
                    choices=['release', 'hotfix', 'snapshot', 'debug'],
                    help='打包类型，默认release')
```

### 带Wiki录入的使用示例
```bash
# 打包并自动录入本地Wiki
python pack.py ./my-project -v 1.2.3 --wiki-root ./local-wiki \
  --changelog "修复登录bug" --changelog "优化首页加载速度"

# 仅初始化Wiki
python wiki_manager_script.py --wiki-root ./local-wiki init

# 查询某软件历史版本
python wiki_manager_script.py --wiki-root ./local-wiki query --name my-app
```

---

## 能力说明
1. **双向打通**：打包动作自动沉淀为知识库条目，无需手动记录
2. **RAG友好**：结构化YAML元数据 + 标准化条目格式，本地大模型可直接检索
3. **独立可用**：Wiki管理能力可单独使用，支持手动录入、批量维护
4. **低耦合**：不强制依赖Wiki，不加 `--wiki-root` 参数时与原打包功能完全一致

需要我补充Shell版本的Wiki录入脚本，或者针对你的项目目录结构调整Wiki模板字段吗？