# Codex Harness Template

Template này dành cho thành viên **VSI.ES** sử dụng Codex trong dự án. Codex đọc `AGENTS.md` tại project root; file này quy định lifecycle, quality gates và cách lưu handoff của harness.

## Setup

1. Sao chép nội dung của thư mục này vào project root:

   ```bash
   cp -a /path/to/harness-codex/. /path/to/your-project/
   cd /path/to/your-project
   ```

2. Cập nhật `init.sh` với bootstrap riêng của dự án (dependencies, build hoặc service). Script phải an toàn khi chạy lại.
3. Thay feature ví dụ trong `feature_list.json` bằng backlog thực tế. Chỉ một feature được `in_progress` tại một thời điểm.
4. Điền các placeholder trong `harness/memory/progress.md` và `harness/memory/session_handoff.md`.
5. Chạy bootstrap trước khi mở Codex:

   ```bash
   bash ./init.sh
   ```

## Chạy harness với Codex

Mở Codex từ project root sau khi bootstrap hoàn tất. Codex đọc `AGENTS.md` và sẽ:

1. Đọc progress, handoff và feature active.
2. Plan → build → test → verify theo phạm vi feature.
3. Ghi evidence, cập nhật state/progress và handoff trước khi kết thúc.

Agent không tự chạy lại `init.sh`; nếu bootstrap lỗi hoặc chưa chạy, hãy xử lý trước khi bắt đầu phiên Codex.

## Kiểm tra nhanh

```bash
bash -n init.sh harness/tests/test_init.sh
bash harness/tests/test_init.sh
python3 -m json.tool feature_list.json >/dev/null
python3 harness/gates/gates.py
```

Xem thêm: `harness/docs/getting-started.md`, `harness/docs/overview.md`, `harness/docs/customization.md`.
