package com.flowerstore.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

/**
 * 文件服务
 */
@Service
public class FileService {

    @Value("${file.upload.path}")
    private String uploadPath;

    @Value("${file.upload.domain}")
    private String domain;

    /**
     * 上传文件
     */
    public String upload(MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            throw new RuntimeException("文件不能为空");
        }

        // 获取原始文件名
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null) {
            throw new RuntimeException("文件名不能为空");
        }

        // 获取文件扩展名
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));

        // 生成新文件名（使用UUID防止重复）
        String newFilename = UUID.randomUUID().toString().replace("-", "") + extension;

        // 按日期创建子目录
        String dateDir = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        Path dirPath = Paths.get(uploadPath, dateDir).toAbsolutePath().normalize();

        // 创建目录
        Files.createDirectories(dirPath);

        // 保存文件（使用 toPath() 避免 Servlet Part.write() 的相对路径问题）
        Path destPath = dirPath.resolve(newFilename);
        file.transferTo(destPath);

        // 返回完整的URL地址
        String relativePath = "/api/uploads/" + dateDir + "/" + newFilename;
        return domain + relativePath;
    }

    /**
     * 删除文件
     */
    public void delete(String filePath) {
        if (filePath == null || filePath.isEmpty()) {
            return;
        }

        // 去除域名和访问路径前缀
        String path = filePath.replace(domain, "").replace("/api/uploads/", "");
        Path realPath = Paths.get(uploadPath, path).toAbsolutePath().normalize();
        File file = realPath.toFile();
        if (file.exists()) {
            file.delete();
        }
    }
}

