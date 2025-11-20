import asyncio
from bilibili_api import video_uploader, Credential
import os
import glob
from datetime import datetime, timedelta

SESSDATA="61e70ace%2C1779163847%2C0c75a%2Ab2CjB9ihWdoZPUhTSy_wKzZTxFn-GrZMf-jmE73eYPy16zbSDZNBrMk1PW4-KwhSmgdv4SVkl3OHJ2YnNKckIzaXc3WHVlbU5QRUc1NVMzZXQxdnl1Nm5kaGRqanp1WlVnOS04Z3RYRUJFTDBDM1g3N0txZy1ZZUpweXBvVnFCQnMwRDZRYi1CTXNnIIEC"
BILI_JCT="60ff1263c5daa897b8a47045536c0009"
BUVID3="6D51D372-A5CC-A3F5-B93F-07B3B7C44A6C39880infoc"

async def main():
    # Get yesterday's date (YYYYMMDD)
    yesterday = (datetime.now()_timedelta(days=1)).strftime("%Y%m%d")
    video_dir = f"/root/Auto_Download_From_NPR/download_NPR/data/video/VIDEO_{yesterday}"
    
    print(f"Looking for videos in: {video_dir}")
    
    # Find all English_Study videos
    video_files = glob.glob(os.path.join(video_dir, "English_Study_*.mp4"))
    video_files.sort()  # Sort by name
    
    if not video_files:
        print("No videos found!")
        return
    
    print(f"Found {len(video_files)} videos:")
    for v in video_files:
        print(f"  {os.path.basename(v)}")
    
    # Create upload pages
    pages = []
    for i, video_path in enumerate(video_files):
        video_name = os.path.basename(video_path).replace('.mp4', '')
        page = video_uploader.VideoUploaderPage(
            path=video_path,
            title=video_name,
            description=video_name
        )
        pages.append(page)
    
    # Create metadata
    credential = Credential(sessdata=SESSDATA, bili_jct=BILI_JCT, buvid3=BUVID3)
    
    vu_meta = video_uploader.VideoMeta(
        tid=208,
        title=f"英语听力 - {yesterday}",
        tags=["英语学习", "听力测试"],
        desc="每日英语听力练习",
        cover="cover.png",
        no_reprint=1,
    )
    
    # Upload
    uploader = video_uploader.VideoUploader(pages, vu_meta, credential)
    
    @uploader.on("__ALL__")
    async def ev(data):
        print(data)
    
    await uploader.start()
    print("Upload completed!")

if __name__ == "__main__":
    asyncio.run(main())
