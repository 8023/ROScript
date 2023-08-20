import requests
from requests.adapters import HTTPAdapter
import os
import re
import shutil

cfg = {
    "path": "/usr/src/app/wwwroot",
    "ua": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.74 Safari/537.36",

    "filter": {
        "v4": r'[0-9\.]{7,15}/?[0-9]{0,2}',
        "v6": r'[0-9a-f:]{6,39}/?[0-9]{0,2}',
    },

    "prefix": {
        "v4": {"prefix": "/ip/firewall/address-list/", "list": "list=", "addr": " address="},
        "v6": {"prefix": "/ipv6/firewall/address-list/", "list": "list=", "addr": " address="},
    },

    "retry": 10,
    "timeout": 60,
}

srcs = {
    "ispip-clang-cn": {
        "url": "https://ispip.clang.cn",
        "suffix": ".txt",
        "item": {
            "adlist-pbr-hk": {"v4": "hk_cidr", "v6": "hk_ipv6"},  # 香港
            "adlist-pbr-mo": {"v4": "mo_cidr", "v6": "mo_ipv6"},  # 澳门
            "adlist-pbr-tw": {"v4": "tw_cidr", "v6": "tw_ipv6"},  # 台湾
            "adlist-pbr-cm": {"v4": "cmcc_cidr", "v6": "cmcc_ipv6"},  # 移动
            "adlist-pbr-gw": {"v4": "gwbn_cidr", "v6": "gwbn_ipv6"},  # 长城宽带、鹏博士宽带
            "adlist-pbr-cn": {"v4": "all_cn_cidr", "v6": "all_cn_ipv6"},  # 大陆
            "adlist-pbr-edu": {"v4": "cernet_cidr", "v6": "cernet_ipv6"},  # 教育网
            "adlist-pbr-oth": {"v4": "othernet_cidr", "v6": "othernet_ipv6"},  # 其它运营商
            "adlist-pbr-cu": {"v4": "unicom_cnc_cidr", "v6": "unicom_cnc_ipv6"},  # 联通、铁通
            "adlist-pbr-ct": {"v4": "chinatelecom_cidr", "v6": "chinatelecom_ipv6"},  # 电信
        }
    },
    "china-operator-ip": {
        "url": "https://raw.githubusercontent.com/gaoyifan/china-operator-ip/ip-lists",
        "suffix": ".txt",
        "item": {
            "adlist-pbr-cm": {"v4": "cmcc", "v6": "cmcc6"},  # 移动
            "adlist-pbr-cu": {"v4": "unicom", "v6": "unicom6"},  # 联通
            "adlist-pbr-edu": {"v4": "cernet", "v6": "cernet6"},  # 教育网
            "adlist-pbr-cst": {"v4": "cstnet", "v6": "cstnet6"},  # 科技网
            "adlist-pbr-tt": {"v4": "tietong", "v6": "tietong6"},  # 铁通
            "adlist-pbr-ct": {"v4": "chinanet", "v6": "chinanet6"},  # 电信
        }
    },
    "ros6-com": {
        "url": "https://cache-1.oss-cn-beijing.aliyuncs.com/file",
        "suffix": ".rsc",
        "item": {
           "adlist-scanner": {"v4": "scaners"},  # 扫描器
        }
    }
}

for src in srcs:
    for isp in srcs[src]["item"]:
        for typ in srcs[src]["item"][isp]:
            dir = cfg["path"] + "/" + src + "/" + typ

            if not os.path.exists(dir):
                os.makedirs(dir)

            url = srcs[src]["url"] + "/" + srcs[src]["item"][isp][typ] + srcs[src]["suffix"]
            path = dir + "/" + isp + ".rsc"

            try:
                r = requests.Session()
                r.mount('https://', HTTPAdapter(max_retries=cfg["retry"]))
                s = r.get(url, timeout=cfg["timeout"]).content.decode("utf-8")
            except:
                print("request error: " + url)
                break

            s = re.findall(cfg["filter"][typ], s, flags=re.M)
            s = list(map(lambda x: "add " + cfg["prefix"][typ]["list"] + isp + cfg["prefix"][typ]["addr"] + x, s))
            s.insert(0, cfg["prefix"][typ]["prefix"])
            s = "\n".join(s)

            if s != "":
                with open(path, "w") as f:
                    f.write(s)

                dir = cfg["path"] + "/" + "general" + "/" + typ
                if not os.path.exists(dir):
                    os.makedirs(dir)
                shutil.copy(path, dir + "/" + isp + ".rsc")
            else:
                try:
                    os.remove(path)
                    print("file deleted: " + path)
                except:
                    print("file not exist: " + path)
                    break

            print("update ok: " + url)
