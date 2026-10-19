# 独立仓库与备份说明

- GitHub 仓库：https://github.com/xee-martin/paygo-home
- 本仓库独立维护 PayGo 静态官网及公开开发文档。
- 初始提交保存当前目录源码，不迁入其他仓库的历史。
- 本地依赖、构建产物、环境变量文件、私密配置及系统文件不上传；忽略规则见 `.gitignore`。
- 恢复时克隆本仓库，并按 `README.md` 预览或部署静态文件。
- 提交身份与推送认证在本地仓库内配置，不修改全局 Git 身份。认证数据不得提交。

后续备份前审查 `git status`，只提交需要保存的源码，再执行 `git push origin main`。
