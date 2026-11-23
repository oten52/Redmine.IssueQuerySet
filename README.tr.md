# Redmine Issue Query Set

Seçilen işleri kayıtlı bir sorguya ekler. Numaralar sorgunun iş listesinin sonuna virgülle yazılır.

[English](README.md)

## Ne yapar

* İş listesinde işleri seçip sağ tıklayın ve **Sorguya ekle** deyin. Küçük pencerede arayıp birden fazla sorgu seçebilirsiniz.
* Sorgu listesini, düzenleyebildiğiniz tüm sorgular veya yalnız bu projenin sorguları olarak süzün.
* Var olan numaralar sırasını korur. Yeni numaralar sona eklenir. Tekrarlar ve fazladan virgüller temizlenir.

Örnek: sorguda `32310,32316` varken `32322` eklenirse kayıt `32310,32316,32322` olur.

## Redmine sürümü

* 4.2.x ~ 6.x

Ek gem, asset derlemesi ve veritabanı göçü gerekmez. Sorguyu ancak Redmine'da zaten düzenleyebiliyorsanız güncelleyebilirsiniz.

## Kurulum

```bash
cd /home/niltek/redmine/app/plugins
sudo -u niltek git clone https://github.com/oten52/Redmine.IssueQuerySet.git
docker restart redmine-redmine-1
```

Klasör adı `Redmine.IssueQuerySet` olarak kalabilir.

## Güncelleme

```bash
cd /home/niltek/redmine/app/plugins/Redmine.IssueQuerySet
sudo -u niltek git pull
docker restart redmine-redmine-1
```
