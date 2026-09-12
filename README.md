﻿# Project-G8-HPD-LAMS

## Database Project Report
**Due Date:** 26/08/2026 - Week 3  
**Project ID & Title:** #8 - Digital Library & Open-Access Repository Management System

---

### A. Project Identity

* **Team Name:** G8
* **Team Members:**
  * Nguyễn Trung Thiện (`n25dcat107@gmail.student.ptithcm.edu.vn`) - GitHub: @thiennguyentrung123-png
  * Trần Nguyễn Quốc Thịnh (`n25dcat109@gmail.student.ptithcm.edu.vn`) - GitHub: @n25dcat109-dotcom
  * Nguyễn Phúc Thịnh (`n22dccn182@gmail.student.ptithcm.edu.vn`) - GitHub: @Darkbreaker2412
* **Project Title:** Design and Implementation of a Relational Database for Academic Open-Access Digital Library and Repository System

---

# Phase 1 — Phân công nhiệm vụ

> **Mục tiêu Phase 1:** Xác định bài toán, yêu cầu nghiệp vụ và thiết kế EER sơ bộ cho hệ thống **Open-Access Repository**.

| Thành viên                 | Phụ trách                           | Nội dung công việc                                                                                                                                                                                                                                                                                                                                                |
| -------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Nguyễn Phúc Thịnh**      | 📄 **Problem Statement & Document** | - Viết **Problem Statement**: mô tả thực trạng quản lý và lưu trữ tài liệu số hiện nay.<br>- Phân tích lý do cần xây dựng **Open-Access Repository**.<br>- Xác định **System Scope**: phạm vi hệ thống, đối tượng sử dụng và các chức năng chính.<br>- Xác định **Project Objectives**: mục tiêu và kết quả mong đợi của dự án.                                   |
| **Trần Nguyễn Quốc Thịnh** | 📋 **Business Rules & Constraints** | - Xây dựng tập **Business Rules** liên quan đến **Tài liệu**: DOI, metadata theo chuẩn **Dublin Core**.<br>- Xác định quy tắc quản lý **Tác giả** và **Đơn vị công tác**.<br>- Xác định quy tắc về **Giấy phép bản quyền**, đặc biệt là **Creative Commons**.<br>- Xác định các **Constraints**: Cardinality, Mandatory/Optional và các ràng buộc nghiệp vụ khác. |
| **Nguyễn Trung Thiện**     | 🗂️ **ER/EER Design & Diagramming** | - Phác thảo các **Entity** chính của hệ thống.<br>- Xác định các **Relationship** giữa các Entity: **1:1, 1:N, N:M**.<br>- Xác định các thuộc tính quan trọng của Entity và Relationship.<br>- Thiết kế các đặc tính **EER**: **Supertype/Subtype**, ví dụ `Người dùng → Tác giả/Độc giả` và `Tài liệu → Bài báo/Luận văn`.<br>- Vẽ **ER/EER Diagram** sơ bộ.     |
