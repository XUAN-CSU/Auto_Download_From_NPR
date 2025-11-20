import asyncio
from bilibili_api import video, Credential

SESSDATA="61e70ace%2C1779163847%2C0c75a%2Ab2CjB9ihWdoZPUhTSy_wKzZTxFn-GrZMf-jmE73eYPy16zbSDZNBrMk1PW4-KwhSmgdv4SVkl3OHJ2YnNKckIzaXc3WHVlbU5QRUc1NVMzZXQxdnl1Nm5kaGRqanp1WlVnOS04Z3RYRUJFTDBDM1g3N0txZy1ZZUpweXBvVnFCQnMwRDZRYi1CTXNnIIEC"
BILI_JCT="60ff1263c5daa897b8a47045536c0009"
BUVID3="6D51D372-A5CC-A3F5-B93F-07B3B7C44A6C39880infoc"

async def main() -> None:
    # 实例化 Credential 类
    credential = Credential(sessdata=SESSDATA, bili_jct=BILI_JCT, buvid3=BUVID3)
    # 实例化 Video 类
    v = video.Video(bvid="BV1fm411o7Kr", credential=credential)
    info = await v.get_info()
    print(info)
    # 给视频点赞
    await v.like(True)

if __name__ == '__main__':
    asyncio.run(main())
