import { promises as fs } from 'fs';
import path from 'path';
import matter from 'gray-matter';

const postsDir = './_posts'; // Markdownファイルが格納されているディレクトリのパスを指定

async function updateFrontMatter() {
  try {
    const files = await fs.readdir(postsDir);
    for (const file of files) {
      if (path.extname(file) === '.md') {
        const filePath = path.join(postsDir, file);
        const content = await fs.readFile(filePath, 'utf8');
        const { data: frontMatter, content: markdownContent } = matter(content);
        const timestamp = Date.now();
        const slug = path.basename(file, '.md'); // ファイル名から拡張子を除いてslugを生成
        frontMatter.slug = frontMatter.slug || slug;
        frontMatter.image = {
          path: `/assets/img/og/${slug}.png?r=${timestamp}`,
          show: false,
        };

        const updatedContent = matter.stringify(markdownContent, frontMatter);
        await fs.writeFile(filePath, updatedContent);
        console.log(`Updated ${file} successfully`);
      }
    }
  } catch (err) {
    console.error('Error updating front matter:', err);
  }
}

updateFrontMatter();
