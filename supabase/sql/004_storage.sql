-- Storage policies for the public product-images bucket.
-- Create the bucket in the dashboard first with id `product-images`.
-- Public reads are handled by the bucket setting; authenticated writes remain
-- restricted to the signed-in seller's first path segment.

begin;

drop policy if exists product_images_read_seller_folder on storage.objects;
create policy product_images_read_seller_folder
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
    and (select private.current_user_role()) = 'seller'
  );

drop policy if exists product_images_insert_seller_folder on storage.objects;
create policy product_images_insert_seller_folder
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
    and (select private.current_user_role()) = 'seller'
    and storage.extension(name) in ('jpg', 'png', 'webp')
  );

drop policy if exists product_images_delete_seller_folder on storage.objects;
create policy product_images_delete_seller_folder
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
    and (select private.current_user_role()) = 'seller'
  );

commit;
